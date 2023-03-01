#!/bin/bash
aws s3 cp s3://${s3_bucket}/cdu/aws-install-cd.sh aws-install-cd.sh
chmod +x aws-install-cd.sh
./aws-install-cd.sh --node-name ${node_name} --s3-bucket ${s3_bucket} --cd-bin ${cd_bin} \
--server-keycert ${server_keycert} --secret-key-prefix ${secret_key_prefix} \
${efs_dns} ${efs_root} --aws-region ${aws_region} \
--root-cert ${root_cert} --issuing-cert ${issuing_cert} \
--global-folder ${global_folder} --local-folder ${local_folder} \
--cdadmin-uid ${cdadmin_uid} --cdadmin-gid ${cdadmin_gid} \
--cw-log-group ${cw_log_group} --overwrite ${overwrite} --proxy-url ${proxy_url} > /tmp/userdata.log 2>&1
