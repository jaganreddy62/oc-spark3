
# Spark Standalone Deployment on OpenShift with DevSecOps

This project provides a full CI/CD pipeline for deploying Apache Spark Standalone mode in OpenShift using:
- Custom Docker image
- Helm chart
- Tekton pipeline
- GitHub Actions trigger
- Trivy vulnerability scan
- S3-based Spark event logs
- DevSecOps compliance

---

## 📁 Project Structure

```
spark-devsecops-helm/
├── Dockerfile                     # Builds Spark image with S3 event logging
├── entrypoint.sh                  # Custom entry script for Spark components
├── helm/
│   └── spark/
│       ├── Chart.yaml             # Helm chart definition
│       ├── values.yaml            # Configuration for Spark master, worker, and history server
│       └── templates/             # Kubernetes templates for deployment
│           ├── master.yaml
│           ├── worker.yaml
│           └── history-server.yaml
├── tekton/
│   ├── build-and-push-image.yaml # Kaniko build + push task
│   ├── tekton-pipeline.yaml      # Complete pipeline
│   └── tekton-task.yaml          # Trivy scan + Helm deploy tasks
└── .github/
    └── workflows/
        └── github-actions-deploy-spark.yaml  # CI trigger from GitHub
```

---

## ⚙️ Usage Guide

### Step 1: Build & Push Docker Image (Tekton)
```yaml
params:
  image: artifactory.myorg.com/spark-custom:latest
```

Make sure your Kaniko executor has access to your Docker config secret.

### Step 2: Trivy Vulnerability Scan
Runs automatically on the pushed image.

### Step 3: Helm Deployment
Installs Spark using your custom chart in `helm/spark/`.

### Step 4: GitHub Actions Trigger
Workflow `github-actions-deploy-spark.yaml` triggers Tekton pipeline on new commits.

---

## 🔐 Secrets & Configuration

### Artifactory Push Auth (Kaniko)
Create a Docker config secret:
```bash
kubectl create secret generic docker-config   --from-file=.dockerconfigjson=<your-config.json>   --type=kubernetes.io/dockerconfigjson
```

Mount it into Tekton service account used by the pipeline.

---

## 🔧 OpenShift Setup

- Make sure your namespace/project is created
- Tekton CLI (`tkn`) must be installed
- Configure your GitHub webhook or personal token in OpenShift for triggers (if needed)

---

## 📦 Deploy the Full Pipeline

### 1. Apply Tekton Tasks & Pipeline
```bash
kubectl apply -f tekton/build-and-push-image.yaml
kubectl apply -f tekton/tekton-task.yaml
kubectl apply -f tekton/tekton-pipeline.yaml
```

### 2. Run Pipeline with `tkn`
```bash
tkn pipeline start spark-deploy-pipeline   -p image=artifactory.myorg.com/spark-custom:latest   -p chart=./helm/spark   -p release=spark-release   -p namespace=devsandbox   --use-param-defaults   -w name=shared-workspace,emptyDir={}
```

### 3. Push Code to GitHub
Triggers GitHub Action defined in:
```bash
.github/workflows/github-actions-deploy-spark.yaml
```

### 4. View Helm Release in OpenShift
```bash
helm list -n devsandbox
```

---

## 📂 Spark Logs in S3

Ensure Spark is configured to write event logs to your S3-compatible storage.

In `values.yaml`:
```yaml
spark:
  historyServer:
    env:
      - name: AWS_ACCESS_KEY_ID
        valueFrom:
          secretKeyRef:
            name: s3-credentials
            key: accessKey
      - name: AWS_SECRET_ACCESS_KEY
        valueFrom:
          secretKeyRef:
            name: s3-credentials
            key: secretKey
```

---

## ✅ DevSecOps Notes

- Trivy scans image before deploy
- Helm deploys only after passing scan
- GitHub Actions acts as CI trigger
- Secrets are managed in OpenShift

---

## 📬 Contact

Feel free to reach out for help integrating Nexus, Vault, or GitOps tools like ArgoCD.
