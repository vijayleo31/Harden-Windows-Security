Function Confirm-CertCN {
    <#
    .SYNOPSIS
        Function to check Certificate Common name - used mostly to validate values in UserConfigurations.json
    .PARAMETER CN
        Common name of the certificate to check
    .INPUTS
        System.String
    .OUTPUTS
        System.Boolean
    .NOTES
        Can receive empty string as input as well for cases when the user configurations file does not contain a certificate CN
    #>
    [CmdletBinding()]
    param (
        [AllowEmptyString()]
        [parameter(Mandatory = $true)][System.String]$CN
    )
    # Importing the $PSDefaultParameterValues to the current session, prior to everything else
    . "$ModuleRootPath\CoreExt\PSDefaultParameterValues.ps1"

    # Create an empty array to store the output objects
    [System.Object[]]$Output = @()

    # Loop through each certificate that uses RSA algorithm (Because ECDSA is not supported for signing WDAC policies) in the current user's personal store and extract the relevant properties
    foreach ($Cert in (Get-ChildItem -Path 'Cert:\CurrentUser\My' | Where-Object -FilterScript { $_.PublicKey.Oid.FriendlyName -eq 'RSA' })) {

        # Takes care of certificate subjects that include comma in their CN
        # Determine if the subject contains a comma
        if ($Cert.Subject -match 'CN=(?<RegexTest>.*?),.*') {
            # If the CN value contains double quotes, use split to get the value between the quotes
            if ($matches['RegexTest'] -like '*"*') {
                $SubjectCN = ($Element.Certificate.Subject -split 'CN="(.+?)"')[1]
            }
            # Otherwise, use the named group RegexTest to get the CN value
            else {
                $SubjectCN = $matches['RegexTest']
            }
        }
        # If the subject does not contain a comma, use a lookbehind to get the CN value
        elseif ($Cert.Subject -match '(?<=CN=).*') {
            $SubjectCN = $matches[0]
        }

        # Create a custom object with the certificate thumbprint, subject, friendly name and subject CN
        $Output += [PSCustomObject]@{
            Thumbprint   = [System.String]$Cert.Thumbprint
            Subject      = [System.String]$Cert.Subject
            FriendlyName = [System.String]$Cert.FriendlyName
            SubjectCN    = [System.String]$SubjectCN
        }
    }

    return [System.Boolean]([System.String[]]$Output.SubjectCN -contains $CN ? $true : $false)
}

# Export external facing functions only, prevent internal functions from getting exported
Export-ModuleMember -Function 'Confirm-CertCN'

# SIG # Begin signature block
# MIILkgYJKoZIhvcNAQcCoIILgzCCC38CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCA7dZCJ2D4iMY7g
# sCB59Fa1mpK7qIMs2Q9coo3Ocbob4KCCB9AwggfMMIIFtKADAgECAhMeAAAABI80
# LDQz/68TAAAAAAAEMA0GCSqGSIb3DQEBDQUAME8xEzARBgoJkiaJk/IsZAEZFgNj
# b20xIjAgBgoJkiaJk/IsZAEZFhJIT1RDQUtFWC1DQS1Eb21haW4xFDASBgNVBAMT
# C0hPVENBS0VYLUNBMCAXDTIzMTIyNzExMjkyOVoYDzIyMDgxMTEyMTEyOTI5WjB5
# MQswCQYDVQQGEwJVSzEeMBwGA1UEAxMVSG90Q2FrZVggQ29kZSBTaWduaW5nMSMw
# IQYJKoZIhvcNAQkBFhRob3RjYWtleEBvdXRsb29rLmNvbTElMCMGCSqGSIb3DQEJ
# ARYWU3B5bmV0Z2lybEBvdXRsb29rLmNvbTCCAiIwDQYJKoZIhvcNAQEBBQADggIP
# ADCCAgoCggIBAKb1BJzTrpu1ERiwr7ivp0UuJ1GmNmmZ65eckLpGSF+2r22+7Tgm
# pEifj9NhPw0X60F9HhdSM+2XeuikmaNMvq8XRDUFoenv9P1ZU1wli5WTKHJ5ayDW
# k2NP22G9IPRnIpizkHkQnCwctx0AFJx1qvvd+EFlG6ihM0fKGG+DwMaFqsKCGh+M
# rb1bKKtY7UEnEVAsVi7KYGkkH+ukhyFUAdUbh/3ZjO0xWPYpkf/1ldvGes6pjK6P
# US2PHbe6ukiupqYYG3I5Ad0e20uQfZbz9vMSTiwslLhmsST0XAesEvi+SJYz2xAQ
# x2O4n/PxMRxZ3m5Q0WQxLTGFGjB2Bl+B+QPBzbpwb9JC77zgA8J2ncP2biEguSRJ
# e56Ezx6YpSoRv4d1jS3tpRL+ZFm8yv6We+hodE++0tLsfpUq42Guy3MrGQ2kTIRo
# 7TGLOLpayR8tYmnF0XEHaBiVl7u/Szr7kmOe/CfRG8IZl6UX+/66OqZeyJ12Q3m2
# fe7ZWnpWT5sVp2sJmiuGb3atFXBWKcwNumNuy4JecjQE+7NF8rfIv94NxbBV/WSM
# pKf6Yv9OgzkjY1nRdIS1FBHa88RR55+7Ikh4FIGPBTAibiCEJMc79+b8cdsQGOo4
# ymgbKjGeoRNjtegZ7XE/3TUywBBFMf8NfcjF8REs/HIl7u2RHwRaUTJdAgMBAAGj
# ggJzMIICbzA8BgkrBgEEAYI3FQcELzAtBiUrBgEEAYI3FQiG7sUghM++I4HxhQSF
# hqV1htyhDXuG5sF2wOlDAgFkAgEIMBMGA1UdJQQMMAoGCCsGAQUFBwMDMA4GA1Ud
# DwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBsGCSsGAQQBgjcVCgQOMAwwCgYIKwYB
# BQUHAwMwHQYDVR0OBBYEFOlnnQDHNUpYoPqECFP6JAqGDFM6MB8GA1UdIwQYMBaA
# FICT0Mhz5MfqMIi7Xax90DRKYJLSMIHUBgNVHR8EgcwwgckwgcaggcOggcCGgb1s
# ZGFwOi8vL0NOPUhPVENBS0VYLUNBLENOPUhvdENha2VYLENOPUNEUCxDTj1QdWJs
# aWMlMjBLZXklMjBTZXJ2aWNlcyxDTj1TZXJ2aWNlcyxDTj1Db25maWd1cmF0aW9u
# LERDPU5vbkV4aXN0ZW50RG9tYWluLERDPWNvbT9jZXJ0aWZpY2F0ZVJldm9jYXRp
# b25MaXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQwgccG
# CCsGAQUFBwEBBIG6MIG3MIG0BggrBgEFBQcwAoaBp2xkYXA6Ly8vQ049SE9UQ0FL
# RVgtQ0EsQ049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZp
# Y2VzLENOPUNvbmZpZ3VyYXRpb24sREM9Tm9uRXhpc3RlbnREb21haW4sREM9Y29t
# P2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZpY2F0aW9uQXV0
# aG9yaXR5MA0GCSqGSIb3DQEBDQUAA4ICAQA7JI76Ixy113wNjiJmJmPKfnn7brVI
# IyA3ZudXCheqWTYPyYnwzhCSzKJLejGNAsMlXwoYgXQBBmMiSI4Zv4UhTNc4Umqx
# pZSpqV+3FRFQHOG/X6NMHuFa2z7T2pdj+QJuH5TgPayKAJc+Kbg4C7edL6YoePRu
# HoEhoRffiabEP/yDtZWMa6WFqBsfgiLMlo7DfuhRJ0eRqvJ6+czOVU2bxvESMQVo
# bvFTNDlEcUzBM7QxbnsDyGpoJZTx6M3cUkEazuliPAw3IW1vJn8SR1jFBukKcjWn
# aau+/BE9w77GFz1RbIfH3hJ/CUA0wCavxWcbAHz1YoPTAz6EKjIc5PcHpDO+n8Fh
# t3ULwVjWPMoZzU589IXi+2Ol0IUWAdoQJr/Llhub3SNKZ3LlMUPNt+tXAs/vcUl0
# 7+Dp5FpUARE2gMYA/XxfU9T6Q3pX3/NRP/ojO9m0JrKv/KMc9sCGmV9sDygCOosU
# 5yGS4Ze/DJw6QR7xT9lMiWsfgL96Qcw4lfu1+5iLr0dnDFsGowGTKPGI0EvzK7H+
# DuFRg+Fyhn40dOUl8fVDqYHuZJRoWJxCsyobVkrX4rA6xUTswl7xYPYWz88WZDoY
# gI8AwuRkzJyUEA07IYtsbFCYrcUzIHME4uf8jsJhCmb0va1G2WrWuyasv3K/G8Nn
# f60MsDbDH1mLtzGCAxgwggMUAgEBMGYwTzETMBEGCgmSJomT8ixkARkWA2NvbTEi
# MCAGCgmSJomT8ixkARkWEkhPVENBS0VYLUNBLURvbWFpbjEUMBIGA1UEAxMLSE9U
# Q0FLRVgtQ0ECEx4AAAAEjzQsNDP/rxMAAAAAAAQwDQYJYIZIAWUDBAIBBQCggYQw
# GAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGC
# NwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQx
# IgQg6bWHvT7HswyOrHK1Hq6QNsgSUIB55mvFkN8CmXL5fckwDQYJKoZIhvcNAQEB
# BQAEggIAM3a3PngWd1xsi5JnJT/dMiOZFsR8c0NnZtglxYip2HtdbJ9jyyVzq9Im
# 4Pq3TGmrwacPYw84JlpzQl4MSdhqmMaaCZVl4skIHRIjPcq3iu+E6eaL4+H7D1Cl
# aiqlmH3E1iRTXE+I53vEiMDspZcLeHKoXkZCFhHc7adJwThZ1c2TLxHzb+lubvp8
# gC7DIe5DZpky1gMpzwMTZY9/i/LrQq2OjpSLM+WnxEpSHi6EcrSEJfHrRt7HeMxd
# oDbnVQ1aHdWrFq7+Dc4kMfjf1YplFd6od171V2GQeiErTYtj5TnjjC8tD/xLQKxf
# rbDL9c3bxMK69vmRqujv5uTpHkbGcoZZ3YD65noE86lG0F5mMBxqBxn0Za0BKrD+
# Tp2dWtSM0a1Y0uP+gyl2POV+m+M7aAzaxAJkFNrpwkHzNxmokIF7PpjC/9DwSR/X
# ITIEi03vN4CYDK2GTMG/DvI3K2qri6eZcOjQLLed3NaLVJ9ZE+py8fybdpVJJcSq
# 3tToF/gxhael3xxKDgvRl2M0Ad50vq+urGKBJE60nFVo6jHrmpgLWE+uNEnLzU7m
# 1J45uVNlvuM74oxI2FuDpfsBP6F/iqkvSD4kIYzmZJHVcs7m1yj91XCtB/sp4wZ/
# XXIVoePfHa9awwwtMcL5+Sp4KhIzXG2jjmH+9JsnKMWGS8DqC5o=
# SIG # End signature block