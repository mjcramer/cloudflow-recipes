#!/usr/bin/env python3

import os

from google.oauth2 import service_account
import googleapiclient.discovery




def test_permissions(project_id):
    """Tests IAM permissions of the caller"""

    # service = googleapiclient.discovery.build(
    #     "cloudresourcemanager", "v1", credentials=credentials
    # )

    # Get credentials
    gcp_credentials = service_account.Credentials.from_service_account_file(
        filename=os.environ['TF_VAR_gcp_credentials'],
        scopes=['https://www.googleapis.com/auth/cloud-platform']
    )

    # Create the Cloud IAM service object
    service = googleapiclient.discovery.build(
        'cloudresourcemanager', 'v1', credentials=gcp_credentials
    )

    permissions = {
        "permissions": [
            "compute.regions.get"
        ]
    }

    request = service.projects().testIamPermissions(
        resource=project_id, body=permissions
    )
    returnedPermissions = request.execute()
    print(returnedPermissions)
    return returnedPermissions




test_permissions(os.environ['TF_VAR_gcp_credentials'])

# service = googleapiclient.discovery.build(
#     'iam', 'v1', credentials=gcp_credentials
# )
# # Call the Cloud IAM Roles API
# # If using pylint, disable weak-typing warnings
# # pylint: disable=no-member
# response = service.roles().list().execute()
# roles = response['roles']

# # Process the response
# for role in roles:
#     print('Title: ' + role['title'])
#     print('Name: ' + role['name'])
#     if 'description' in role:
#         print('Description: ' + role['description'])
#     print('')