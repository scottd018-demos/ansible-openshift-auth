# Summary

This repo serves as a demonstration for how to authenticate against the OpenShift API with Ansible, given
either a username/password for basic authentication or a service account token for an existing service
account in the cluster.


## Basic Authentication

The following describes only the flow for basic authentication looks as follows:

1. [A user is created in OpenShift](https://docs.redhat.com/en/documentation/openshift_container_platform/4.18/html/authentication_and_authorization/configuring-identity-providers#identity-provider-creating-htpasswd-file-linux_configuring-htpasswd-identity-provider) (or a pre-existing user is selected).  Right now, this may only be an HTPasswd user:

```bash
# create the htpasswd file
htpasswd -c -B demo.htpasswd demo-user
New password: 
Re-type new password: 
Adding password for user demo-user

# create the htpasswd secret
oc create secret generic demo-user --from-file=demo.htpasswd -n openshift-config

# append the new htpasswd identity provider to the cluster OAuth resource .identityProviders section
oc edit oauth cluster
...
identityProviders:
  - name: demo
    mappingMethod: claim
    type: HTPasswd
    htpasswd:
      fileData:
        name: demo-user
```

2. Next, the user provides the above basic authentication credentials to the OpenShift OAuth endpoint.

3. The OpenShift API responds with a token.

4. The token is used to make followon API calls to the OpenShift API.

5. Kubernetes RBAC restricts the token based on what access it has via `ClusterRole`, `ClusterRoleBinding`, `Role` 
and `RoleBinding` resources.


## Service Account Authentication

The flow for service account authentication looks as follows:

1. Create the service account:

```bash
oc -n default create sa demo-sa
```

2. Assign the RBAC.  The below assigns full admin privileges via the `cluster-admin` role, but you can use any role
you would like (or create one) to restrict the ability of the service account:

```bash
oc adm policy add-cluster-role-to-user cluster-admin -z demo-sa -n default
```

3. Fetch a service account token:

```bash
oc -n default create token demo-sa
```

## Input Variables

The following describes the input variables to run this demo:

| Variable Name | Description | Vaulted | Required |
| --- | --- | --- | --- |
| `openshift_username` | When using [basic auth](#basic-authentication), the username of the user to use | Yes (`vault.yaml`) | No.  One of username and password or service account must be used. |
| `openshift_username` | When using [basic auth](#basic-authentication), the password associated with the `openshift_username` of the user to use | Yes (`vault.yaml`) | No.  One of username and password or service account must be used. |
| `openshift_service_account_token` | When using [service account auth](#service-account-authentication), the token of the service account | Yes (`vault.yaml`) | No.  One of username and password or service account must be used. |
| `openshift_api_url` | The URL of the API server, prefaced with `https://` | Yes (`vault.yaml`) | Yes |
| `openshift_oauth_endpoing_url` | The URL of the OAuth endpiong, prefaced with `https://` | Yes (`vault.yaml`) | Yes |


## Run the Demo

1. First, setup the virtualenv, install Ansible, and all required Python packages:

```bash
make setup
```

2. Next, define the variables, which are protected by Vault:

```bash
source venv/bin/activate
ansible-vault edit vault.yaml
```

3. Finally, run the demo:

```bash
make demo
```
