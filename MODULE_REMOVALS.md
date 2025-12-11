# Module Removals Documentation

This document explains the reasons for removing three modules from the AWS DRS POC project and the impact of these removals.

## 1. Analytics Module (Removed)

### Why it was unnecessary
- A Disaster Recovery (DR) environment is designed for recovery operations, not for analytics workloads
- Analytics workloads should be performed in the production environment, not in DR
- The module was creating resources that would rarely, if ever, be used in a DR scenario

### Components removed
- Redshift cluster
- Redshift subnet group
- Security group for Redshift
- S3 bucket for analytics data
- IAM roles and policies for Redshift-S3 access
- Glue Catalog Database

### Cost impact
- Elimination of Redshift cluster costs, which can be significant
- Reduction in S3 storage costs for analytics data

### Simplification benefit
- Reduced complexity in the DR environment
- Fewer resources to manage and maintain
- More focused architecture aligned with DR purpose

## 2. CICD Module (Removed)

### Why it was unnecessary
- DR environments typically don't require active CI/CD pipelines
- Application deployments in a DR scenario would likely be performed directly or through recovery processes
- CI/CD resources are development-focused and not core to DR functionality

### Components removed
- CodeCommit repository
- S3 bucket for build artifacts
- IAM roles and policies for CodeBuild and CodePipeline
- CodeBuild project
- CodePipeline pipeline

### Cost impact
- Eliminates costs associated with CI/CD infrastructure
- Reduces S3 storage costs for artifacts

### Simplification benefit
- Removes configurations that would rarely be used in a DR scenario
- Simplifies the overall architecture
- Focuses the DR environment on its primary purpose

## 3. Infracost Module (Removed)

### Why it was unnecessary
- This was a utility module for cost estimation during development
- It's not part of the actual infrastructure that would be deployed
- Cost estimation can be performed separately from the main infrastructure code

### Components removed
- Infracost configuration files
- Cost estimation scripts
- Various environment-specific tfvars files for cost scenarios

### Cost impact
- Minimal direct cost impact, but simplifies the codebase
- Reduces potential confusion between estimation and actual deployment

### Simplification benefit
- Removes unused code and configurations
- Clarifies the distinction between infrastructure code and development utilities
- Makes the codebase more maintainable

## Overall Improvements Achieved

By removing these modules, we've achieved several important improvements:

1. **Focused DR Architecture**: The infrastructure now focuses exclusively on core DR functionality
2. **Cost Optimization**: Removed resources that would be rarely used but still incur costs
3. **Reduced Complexity**: Simplified the overall architecture and reduced maintenance overhead
4. **Cleaner Codebase**: Removed unnecessary variables and module references
5. **Better Alignment with DR Purpose**: The infrastructure now better aligns with the true purpose of a DR environment for a banking application

These changes improve the maintainability, cost-effectiveness, and focus of the DR solution.