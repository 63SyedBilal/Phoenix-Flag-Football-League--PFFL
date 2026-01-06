# Android Build Signing Setup (CI/CD)

To enable secure release builds in GitHub Actions, you need to configure your repository secrets.

## Prerequisites
You need your `pffl_key.jks` file and its password.

## Step 1: Encode your Keystore
Run this command in your terminal to get the Base64 representation of your keystore file:

```bash
# On Linux/macOS:
base64 -w 0 android/app/pffl_key.jks > b64.txt

# On Windows (PowerShell):
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android/app/pffl_key.jks")) | Out-File -Encoding ASCII b64.txt
```

## Step 2: Add GitHub Secrets
Go to your repository on GitHub: **Settings > Secrets and variables > Actions**. Add the following secrets:

1.  `KEYSTORE_BASE64`: Paste the content of `b64.txt`.
2.  `KEYSTORE_PASSWORD`: Your keystore password.
3.  `KEY_ALIAS`: Your key alias (default is `pffl`).
4.  `KEY_PASSWORD`: Your key password.

## Step 3: Update GitHub Actions Workflow
Add these steps to your workflow (usually in `.github/workflows/build.yml`) before the `flutter build` step:

```yaml
      - name: Decode Keystore
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/pffl_key.jks

      - name: Build APK (Release)
        run: flutter build apk --release
        env:
          KEYSTORE_FILE_PATH: "pffl_key.jks"
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
```

> [!NOTE]
> The `KEYSTORE_FILE_PATH` is relative to the `android/app` directory because of how Gradle is configured in this project.
