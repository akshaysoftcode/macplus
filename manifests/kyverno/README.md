# Kyverno — install and test

## 1. Connect kubectl to the cluster

```bash
aws eks update-kubeconfig --name devsecops-demo-stage-eks --region ap-south-1
kubectl get nodes   # sanity check - should list your node(s)
```

## 2. Install Kyverno via Helm

```bash
helm repo add kyverno https://kyverno.github.io/kyverno/
helm repo update
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```

Wait for it to be ready before applying policies:

```bash
kubectl -n kyverno wait --for=condition=Ready pod -l app.kubernetes.io/component=admission-controller --timeout=180s
```

## 3. Apply the policies

```bash
kubectl apply -f manifests/kyverno/policies/
kubectl get clusterpolicies   # should list all 4, STATUS: Ready
```

All four are set to `validationFailureAction: Enforce` — they actually
block non-compliant resources, not just report on them. (Kyverno's other
mode, `Audit`, would log violations without blocking — useful for
rolling out a new policy gradually in a real environment, but the
chapter's requirement is an actual admission-control gate, so Enforce is
the right choice here.)

## 4. Test each policy - confirm it actually denies

Each file in `manifests/kyverno/test-violations/` deliberately breaks
exactly one policy. Applying each should be REJECTED at admission time,
before the pod is even scheduled - that's the thing to screenshot for
Chapter 13.

```bash
kubectl apply -f manifests/kyverno/test-violations/test-latest-tag.yaml
kubectl apply -f manifests/kyverno/test-violations/test-privileged.yaml
kubectl apply -f manifests/kyverno/test-violations/test-no-limits.yaml
kubectl apply -f manifests/kyverno/test-violations/test-root-user.yaml
```

Expected result for all four: an error like
`error: admission webhook "validate.kyverno.svc-fail" denied the request`
with a message naming the specific policy that blocked it. None of these
pods should actually get created - `kubectl get pods` right after should
show nothing new.

## 5. Confirm a COMPLIANT pod is allowed through

```bash
kubectl apply -f manifests/kyverno/test-violations/test-compliant.yaml
kubectl get pods compliant-test
kubectl delete -f manifests/kyverno/test-violations/test-compliant.yaml
```

This one should succeed — proving the policies block bad configs
without blocking good ones (a policy that rejects everything isn't a
useful test).
