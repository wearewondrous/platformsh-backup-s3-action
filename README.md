# platformsh-backup-s3-action

## Setup
Create workflow yml file and use the example below to configure the project.
```$ touch .github/workflows/mybackups.yml```
```yml
name: Sync Backups
on:
  pull_request:
jobs:
  upload-backup:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: wearewondrous/platformsh-backup-s3-action@v1
        with:
          project_name: 'my-project' # required.
          gh_repository: ${{ github.repository }}  # required.
          gh_user: 'myuser' # required.
          platformsh_project: 'abcdefghijkl'  # required.
          platformsh_environment: 'master'  # required.
          aws_s3_bucket: 'my-bucket'  # required.
          with_private_files: 'no' # optional default
          public_files_path: 'web/sites/default/files' # optional default
          private_files_path: 'private' # optional default
        env:
          PLATFORMSH_CLI_TOKEN: ${{ secrets.PLATFORMSH_CLI_TOKEN }}
          GH_ACCESS_TOKEN: ${{ secrets.GH_ACCESS_TOKEN }}
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_DEFAULT_REGION: ${{ secrets.AWS_DEFAULT_REGION }}
```
Set the required INPUT variables and add github secrets.
