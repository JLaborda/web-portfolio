# Contract: IAM and state

Trust and the simulation checks. Role names and the exact subject strings are in [data-model.md](../data-model.md).

## Provider

| Field | Value |
|-------|--------|
| URL | `https://token.actions.githubusercontent.com` |
| Audience | `sts.amazonaws.com` |
| Subject prefix | `repo:JLaborda@15078416/web-portfolio@1427090788` |

The thumbprint is read from GitHub's current OIDC certificate when `t02` is implemented. This plan does not invent one.

## Simulation rule

`aws iam simulate-principal-policy` is one action and one `--resource-arns` value per invocation. `EvalDecision` is the result for that pair. `allowed` on a forbidden pair fails the task. The command list is in [tasks.md](../tasks.md) under `t02`.

## State boundary

`infra/site` is applied twice. The backend key and `-var environment` select the environment. Staging state does not include production resources.
