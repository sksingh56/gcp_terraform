FROM alpine:latest AS builder

COPY hashicorp.asc hashicorp.asc
RUN apk add --update git curl openssh gpgme && \
    gpg --import hashicorp.asc

ARG TERRAFORM_VERSION
ENV TERRAFORM_VERSION ${TERRAFORM_VERSION:-0.11.8}

LABEL TERRAFORM_VERSION=${TERRAFORM_VERSION}

RUN curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig && \
    gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS && \
    cat terraform_${TERRAFORM_VERSION}_SHA256SUMS | grep linux_amd64.zip | sha256sum -c && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /bin

FROM gcr.io/cloud-builders/gcloud

COPY --from=builder /bin/terraform /bin/terraform

ENTRYPOINT ["/bin/terraform"]
# # Use a base image with Terraform and any other necessary tools
# FROM hashicorp/terraform:light

# # Set the working directory inside the container
# WORKDIR /app

# # Copy your Terraform configuration files to the container
# COPY . /app

# # (Optional) Install any additional dependencies or tools required for your Terraform configuration
# # For example, if you need the Google Cloud SDK for GCP resources
# # RUN apt-get update && apt-get install -y google-cloud-sdk

# # (Optional) Provide your GCP service account key file
# # COPY service-account-key.json /app/service-account-key.json

# # (Optional) Set environment variables for GCP authentication
# # ENV GOOGLE_APPLICATION_CREDENTIALS=/app/service-account-key.json

# # Run Terraform commands when the container starts
# # You can customize the commands based on your needs
CMD ["terraform", "init"]