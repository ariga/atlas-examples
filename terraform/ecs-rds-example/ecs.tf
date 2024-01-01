module "ecs" {
  cluster_name               = "atlasdemo"
  source                     = "terraform-aws-modules/ecs/aws"
  version                    = "5.7.4"
  create_task_exec_iam_role  = true
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        base   = 0
        weight = 1
      }
    }
  }
}

locals {
  command = <<EOF
  echo 'env { name = atlas.env \n url = getenv("ATLAS_DB_URL") \n }' > atlas.hcl"
  EOF
}

data "aws_secretsmanager_secret" "atlas-cloud" {
  name = "atlas-cloud-token"
}


resource "aws_ecs_task_definition" "this" {
  container_definitions = jsonencode([
    {
      name       = "atlas",
      image      = "arigaio/atlas:latest-alpine",
      essential  = false,
      entryPoint = ["sh", "-c"],
      command    = ["echo 'env { \n name = atlas.env \n url = getenv(\"ATLAS_DB_URL\") \n }' > atlas.hcl && ./atlas migrate apply --env prod --dir atlas://workshop-demo",]
      secrets    = [
        { name = "ATLAS_DB_URL", valueFrom = aws_secretsmanager_secret.db_url.arn },
        { name = "ATLAS_TOKEN", valueFrom = data.aws_secretsmanager_secret.atlas-cloud.arn }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          awslogs-group         = module.ecs.cloudwatch_log_group_name
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    {
      essential    = true,
      image        = "nginx:latest",
      name         = "backend",
      portMappings = [{ containerPort = 80 }],
      healthCheck  = {
        command     = ["CMD-SHELL", "curl -f http://localhost:80 || exit 1 "],
        interval    = 30,
        timeout     = 5,
        retries     = 3,
        startPeriod = 30
      },
      depends_on = [
        {
          container_name = "atlas",
          condition      = "SUCCESS"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          awslogs-group         = module.ecs.cloudwatch_log_group_name
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  cpu                      = 256
  execution_role_arn       = module.ecs.task_exec_iam_role_arn
  family                   = "atlas-demo"
  memory                   = 512
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
}

resource "aws_ecs_service" "this" {
  cluster         = module.ecs.cluster_id
  desired_count   = 1
  launch_type     = "FARGATE"
  name            = "atlasdemo-service"
  task_definition = resource.aws_ecs_task_definition.this.arn

  lifecycle {
    ignore_changes = [desired_count]
    # Allow external changes to happen without Terraform conflicts, particularly around auto-scaling.
  }

  network_configuration {
    security_groups  = [module.vpc.default_security_group_id]
    subnets          = module.vpc.public_subnets
    assign_public_ip = true
  }
}

# Create an IAM policy that allows reading the secret
resource "aws_iam_policy" "secretsmanager_read" {
  name        = "secretsmanager_read"
  description = "Allows reading secrets from Secrets Manager"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Action   = "secretsmanager:GetSecretValue",
        Resource = aws_secretsmanager_secret.db_url.arn,
        Effect   = "Allow"
      }
    ]
  })
}

# Attach the policy to the ECS task execution role
resource "aws_iam_role_policy_attachment" "secretsmanager_read" {
  role       = module.ecs.task_exec_iam_role_name
  policy_arn = aws_iam_policy.secretsmanager_read.arn
}

# Add the secret as an environment variable in the task defi