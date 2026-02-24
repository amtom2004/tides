runcmd:
  - echo "${app_base64}" | base64 -d > /home/ubuntu/app.py
  - chown ubuntu:ubuntu /home/ubuntu/app.py
  - nohup python3 /home/ubuntu/app.py > /home/ubuntu/app.log 2>&1 &