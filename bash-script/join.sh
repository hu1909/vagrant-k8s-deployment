#!/bin/bash

kubeadm join 192.168.56.2:6443 --token r9800i.0ktj1yyoxmjxvwxq --discovery-token-ca-cert-hash sha256:d1cef5858518066fe1b5fae0e59c0d0fa067ba6a5b44525cd8af3ad2c8ab116d 
kubeadm join 192.168.56.10:6443 --token 158dm3.1abn8hohxpgg35la --discovery-token-ca-cert-hash sha256:ce49ccdde1a97d34bcd858815e3b36edcd1c531ffb2bea0485797bd01189c8c7 
kubeadm join 192.168.56.10:6443 --token sw4b80.25di897oc7l1q5p7 --discovery-token-ca-cert-hash sha256:f6e83c9f913f04c2e9d2bdfb183f89f2b8b483d5bb34a846970aa01dcdb136e6 
kubeadm join 192.168.56.10:6443 --token wopgd1.uis37fgbp15jnz3r --discovery-token-ca-cert-hash sha256:8de59a5cb8bb4f03007bb748f66f630d068ea99e72db816646c1e99681779768 
