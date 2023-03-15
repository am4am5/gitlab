ncdu /var/nfs2

kubectl -n gitlab exec -it <pod> -- registry garbage-collect -m /etc/docker/registry/config.yml

kubectl -n gitlab exec -it `kubectl get pods -n gitlab -l app=registry -o jsonpath='{.items[0].metadata.name}'` -- registry garbage-collect -m /etc/docker/registry/config.yml

#Test CJ
kubectl -n gitlab create job --from=cronjob/garbagecollect garbagecollect01

#garbagecollect.yml

kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  namespace: gitlab
  name: garbagecollect
rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["pods/exec"]
  verbs: ["create"]

---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: garbagecollect
  namespace: gitlab
subjects:
- kind: ServiceAccount
  name: sa-garbagecollect
  namespace: gitlab
roleRef:
  kind: Role
  name: garbagecollect
  apiGroup: ""

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sa-garbagecollect
  namespace: gitlab

---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: garbagecollect
  namespace: gitlab
spec:
  schedule: "0 5 * * 0"
  jobTemplate:
    spec:
      template:
        spec:
          serviceAccountName: sa-garbagecollect
          containers:
          - name: garbagecollect
            image: registry.edo.iba/edo/next/kubectl:1.24.2-debian-11-r2
            command:
            - /bin/sh
            - -c
            - kubectl -n gitlab exec -it `kubectl get pods -n gitlab -l app=registry -o jsonpath='{.items[0].metadata.name}'` -- registry garbage-collect -m /etc/docker/registry/config.yml
          imagePullSecrets:
          - name: reg-cred
          restartPolicy: OnFailure
