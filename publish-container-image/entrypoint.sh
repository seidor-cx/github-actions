#!/bin/bash
mkdir -p /kaniko/.docker
echo "{\"auths\":{\"${{ secrets.CI_REGISTRY }}\":{\"auth\":\"$(printf "%s:%s" "${{ secrets.CI_REGISTRY_USER }}" "${{ secrets.CI_REGISTRY_PASSWORD }}" | base64 | tr -d '\n')\"}}}" > /kaniko/.docker/config.json
/kaniko/executor --skip-tls-verify --context "${{ inputs.build_context }}" --dockerfile "${{ inputs.build_context }}/Dockerfile" --no-push --destination "${CI_REGISTRY_IMAGE}:${{ }}"