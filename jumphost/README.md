## Jump Host





~/.ssh/config

```
Host *
    Port 22
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    ServerAliveInterval 60
    ServerAliveCountMax 30

Host jumphost
    HostName 20.107.24.94
    User alessandro
    IdentityFile ~/.ssh/id_rsa
```

inventory.ini

```
[deployment]
webvm ansible_host=10.0.1.4 ansible_user=alessandro ansible_ssh_private_key_file=~/.ssh/id_rsa
[deployment:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -W %h:%p -q jumphost"'
```

playbook.yml
```
- hosts: all
  become: yes
  tasks:
    - name: ensure nginx is at the latest version
      apt: name=nginx state=latest
    - name: start nginx
      service:
          name: nginx
          state: started
```


ansible-playbook -i ansible/inventory.ini ansible/playbook.yml


https://blog.ruanbekker.com/blog/2020/10/26/use-a-ssh-jump-host-with-ansible/
https://medium.com/@praneeth1691/running-ansible-with-ssh-agent-forwarding-957bcb14c95c



### how to remove single resources

https://www.devopsschool.com/blog/how-to-destroy-one-specific-resource-from-tf-file-in-terraform/