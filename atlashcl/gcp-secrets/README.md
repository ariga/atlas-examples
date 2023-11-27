# atlas-gcp-secrets-demo

Demo of provisioning and reading secrets

## Reading Secrets from GCP Secret Manager

### 1. Create a ServiceAccount for the pipeline to run

We need to create a service account which our GitHub Actions pipeline will use to read the secrets from GCP Secret Manager.

```
export PROJECT_ID=$(gcloud config get-value project)
gcloud iam service-accounts create github-actions-atlas --description="Service account to read secrets" --display-name="GitHub Actions Atlas Workflow"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:github-actions-atlas@$PROJECT_ID.iam.gserviceaccount.com" --role="roles/secretmanager.secretAccessor"
gcloud projects add-iam-policy-binding $PROJECT_ID --member="serviceAccount:github-actions-atlas@$PROJECT_ID.iam.gserviceaccount.com" --role="roles/secretmanager.viewer"
```

```secretmanager.viewer``` is required because `secretmanager.versions.get` permission is required to read secrets.

### 2. Save the ServiceAccount key as a secret

Next, we need to save the service account key as a secret in GitHub Actions so that it can be used by the pipeline.

Create the key and save it as a file:
```
gcloud iam service-accounts keys create github-actions-atlas.json --iam-account=github-actions-atlas@$PROJECT_ID.iam.gserviceaccount.com
gh secret set GCP_SA_KEY < github-actions-atlas.json  # run this from within your repo 
```

Remove the file:
```
rm github-actions-atlas.json
```

### 3. Creating the secrets

Save your Atlas Cloud token to a GCP secret:

```
echo -n "aci_...." | gcloud secrets create atlas-cloud-token --data-file=-
```

### 4. Setup your `atlas.hcl` file

Create a file named `atlas.hcl` with the following contents:

```hcl
// Read the Atlas Cloud token from GCP Secret Manager.
data "runtimevar" "atlas-cloud-token" {
  url = "gcpsecretmanager://projects/atlas-gcp-examples/secrets/atlas-cloud-token"
}

atlas {
  cloud {
    // Use the Atlas Cloud token from the runtimevar data source.
    token = data.runtimevar.atlas-cloud-token
  }
}

env "local" {
  src = "schema.hcl"
  dev = "sqlite://?mode=memory"
}
```

## Setup the pipeline

[Full example](../../.github/workflows/atlashcl-gcp-secrets.yaml)

In your GitHub Action workflow, add the following step, before running any Atlas steps.

```yaml
      - id: 'auth'
        name: 'Authenticate to Google Cloud'
        uses: 'google-github-actions/auth@v1'
        with:
          credentials_json: '${{ secrets.GCP_SA_KEY }}'
```
This will authenticate the pipeline to GCP using the service account key we created earlier
which is stored as a GitHub Actions secret.

Next, make sure that any Atlas steps use the correct atlas.hcl file. For example

```yaml
      - uses: ariga/setup-atlas@v0 # <-- Installs atlas. 
      - uses: ariga/atlas-action/migrate/lint@v1
        with:
          dir: 'file://migrations'
          dir-name: 'gcp-secrets'
          dev-url: 'sqlite://dev?mode=memory'
          config: file://atlas.hcl
        env:
          GITHUB_TOKEN: ${{ github.token }}
```