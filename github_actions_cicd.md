# CI/CD with GitHub Actions, ArgoCD, and Argo Rollouts

In this step, we integrate our **Guestbook application** with **GitHub Actions for CI** and **ArgoCD + Argo Rollouts for CD**.  
The workflow ensures that whenever code is pushed to the `staging` branch, a new Docker image is built, pushed to Docker Hub, and the corresponding **Kustomize overlay** for staging is updated. ArgoCD then takes care of syncing the updated manifests to the cluster.

---

## Workflow Overview

- **CI (Continuous Integration)**:  
  - Runs on GitHub Actions.  
  - Installs dependencies, runs tests, builds a Docker image, and pushes it to Docker Hub.  

- **CD (Continuous Deployment)**:  
  - Uses ArgoCD to pull the latest manifests from GitHub.  
  - Uses Kustomize overlays for environment-specific deployment.  
  - Uses Argo Rollouts for progressive delivery (blue-green/canary).  

---

## Prerequisites

Before using this GitHub Actions workflow, make sure you have:

1. A **Docker Hub account** and created a repo (e.g., `dockerhub_username/guestbook`).
2. An **ArgoCD setup** in your Kubernetes cluster.
3. A **GitOps manifests repository** (e.g., `udemykcloud/Argocd`) where your Kustomize overlays are stored.
4. GitHub **secrets configured**:
   - `DOCKERHUB_USERNAME`
   - `DOCKERHUB_PASSWORD`
   - `ARGO_GITHUB_TOKEN` (a personal access token with repo access).

---

## GitHub Actions Workflow File

Create the following file in your app repository:

```
.github/workflows/staging.yml
```

### Example Workflow: `staging.yml`

```yaml
name: Guestbook CI/CD - Staging

on:
  push:
    branches:
      - staging

permissions:
  contents: write

jobs:
  build-and-deploy-staging:
    runs-on: ubuntu-latest

    env:
      IMAGE_NAME: ${{ secrets.DOCKERHUB_USERNAME }}/guestbook
      DOCKERHUB_USERNAME: ${{ secrets.DOCKERHUB_USERNAME }}
      DOCKERHUB_PASSWORD: ${{ secrets.DOCKERHUB_PASSWORD }}
      COMMIT_EMAIL: "github-actions@example.com"
      COMMIT_NAME: "GitHub Actions"
      MANIFESTS_REPO: "udemykcloud/Argocd"

    steps:
    - name: Checkout Staging Branch
      uses: actions/checkout@v4
      with:
        ref: staging

    - name: Set up Python
      uses: actions/setup-python@v5
      with:
        python-version: '3.11'

    - name: Install backend dependencies
      run: |
        pip install -r app/requirements.txt
        pip install pytest pytest-cov

    - name: Run backend tests (ignore failures)
      run: pytest --cov=app --cov-report=term-missing app/
      continue-on-error: true

    - name: Log in to Docker Hub
      run: echo "${DOCKERHUB_PASSWORD}" | docker login -u "${DOCKERHUB_USERNAME}" --password-stdin

    - name: Build and push Docker image
      run: |
        IMAGE_TAG="staging-$(date +%Y%m%d-%H%M%S)-${GITHUB_SHA::7}"
        echo "IMAGE_TAG=${IMAGE_TAG}" >> $GITHUB_ENV
        docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ./app
        docker push ${IMAGE_NAME}:${IMAGE_TAG}

    - name: Update Staging Manifest in Separate Repo
      run: |
        git clone https://x-access-token:${{ secrets.ARGO_GITHUB_TOKEN }}@github.com/${MANIFESTS_REPO}.git manifests-repo
        cd manifests-repo

        git checkout staging
        OVERLAY_PATH="kustomization-guestbook-multiple-environment/Overlays/staging"

        cd $OVERLAY_PATH
        kustomize edit set image ${IMAGE_NAME}=${IMAGE_NAME}:${IMAGE_TAG}
        cd ../../..

        git config --global user.email "${COMMIT_EMAIL}"
        git config --global user.name "${COMMIT_NAME}"
        git add ${OVERLAY_PATH}/kustomization.yaml
        git commit -m "Staging: Update image to ${IMAGE_NAME}:${IMAGE_TAG}" || echo "No changes to commit"
        git push origin staging
```

---

## What Happens in This Workflow?

1. **Trigger**: Any push to the `staging` branch starts the workflow.  
2. **Tests**: Installs Python dependencies and runs tests (non-blocking).  
3. **Build & Push Image**: Builds a Docker image with a unique tag and pushes to Docker Hub.  
4. **Update Manifests Repo**:  
   - Clones the GitOps repo (used by ArgoCD).  
   - Updates the `kustomization.yaml` in `overlays/staging` with the new image tag.  
   - Commits and pushes changes back to the repo.  
5. **ArgoCD Sync**:  
   - ArgoCD detects changes in the GitOps repo.  
   - Applies the staging overlay.  
   - Uses Argo Rollouts to perform a staged rollout.  

---

## Next Steps for Learners

1. Configure GitHub secrets as described in the prerequisites.  
2. Copy the `staging.yml` workflow into your app repository.  
3. Push code to the `staging` branch and observe:  
   - GitHub Actions building and pushing the image.  
   - The manifests repo being updated.  
   - ArgoCD deploying the updated image into the staging environment.  

✅ With this setup, you now have a **full CI/CD pipeline** using GitHub Actions, Kustomize, ArgoCD, and Argo Rollouts.
