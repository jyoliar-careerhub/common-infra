# On-Premise 모의 환경 Terraform 프로젝트

## 개요

Kubernetes on-premise 환경을 AWS에서 모의 구축하기 위한 Terraform 프로젝트입니다.
VPC는 유지하고, **server 워크스페이스만 생성/제거**하여 비용을 관리합니다.

## 디렉토리 구조

```
for-onpremise/
├── _modules/           # 공통 모듈
│   ├── tfc_remote_state/
│   ├── vpc/
│   ├── subnets/
│   └── nat/
├── vpc/                # VPC 워크스페이스 (유지)
└── server/             # Server 워크스페이스 (생성/제거 대상)
```

## 워크스페이스

| 워크스페이스 | Terraform Cloud | 용도 | 상태 |
|-------------|-----------------|------|------|
| vpc | onpremise-vpc | VPC, Subnets, Route Tables | 항상 유지 |
| server | onpremise-server | NAT, EC2, NLB, Route53, IAM | 필요시 생성/제거 |

## 주요 명령어

### Server 리소스 생성
```bash
cd for-onpremise/server
terraform apply --auto-approve
```

### Server 리소스 제거
```bash
cd for-onpremise/server
terraform destroy --auto-approve
```

## EC2 인스턴스 구성

| 인스턴스명 | 역할 | 타입 | Private IP |
|-----------|------|------|------------|
| ansible-server | Ansible 관리 서버 | t4g.small | 동적 (public subnet) |
| k8s-master-0 | K8s Control Plane | t4g.large | 10.0.25.101 |
| k8s-master-1 | K8s Control Plane | t4g.large | 10.0.25.102 |
| k8s-master-2 | K8s Control Plane | t4g.large | 10.0.25.103 |
| k8s-worker-0 | K8s Worker Node | t4g.large | 10.0.25.104 |
| k8s-worker-1 | K8s Worker Node | t4g.large | 10.0.25.105 |
| k8s-worker-2 | K8s Worker Node | t4g.large | 10.0.25.106 |

- Worker 노드: 100GB gp3 EBS 추가
- AMI: Ubuntu 24.04 LTS (ARM64)
- Region: ap-south-1

## 네트워크

- VPC CIDR: 10.0.0.0/16
- EKS Private Subnet: 10.0.25.0/24 (k8s 노드 배치)
- Core Public Subnet: NAT 인스턴스, ansible-server 배치

## 변수

`env`와 `region`은 Terraform Cloud 워크스페이스에서 주입됩니다.
- env: onpremise
- region: ap-south-1

## 도메인

- ansible.jyo-liar.com - Ansible 서버
- k8s.jyo-liar.com - K8s API (NLB)

## 주의사항

1. **vpc 워크스페이스는 destroy 하지 마세요** - server가 의존합니다
2. server 생성 전 vpc가 apply 되어 있어야 합니다
3. AWS provider 버전은 `_modules/nat/version.tf`와 `server/providers.tf`가 동일해야 합니다 (현재 6.27.0)
