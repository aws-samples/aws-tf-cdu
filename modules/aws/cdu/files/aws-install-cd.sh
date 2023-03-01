###############################################################################
# Variables
###############################################################################
#defaults
#NODE_NAME=
#CW_LOG_GROUP
#EFS_DNS=fs-0ebb56bdc523b3961
#EFS_ROOT=/dev/aws-tf-cdu/cdu/USLDCDUC01
#SERVER_KEYCERT=
REGION=us-east-1
S3_BUCKET_CD_BINS=aws-tf-cdu-dev-terraform-state-bucket
IBM_CD_BIN=IBM_CD_V6.2_UNIX_RedHat.Z.tar.Z
SECRET_KEY_PREFIX=/aws-tf-cdu/dev/cdu
ROOT_CERT=ca-cert.cer
ISSUING_CERT=issuer-cert.cer
GLOBAL_INSTALL_BASE=/opt/IBM/ConnectDirect
LOCAL_INSTALL_BASE=/home/cdadmin
CDADMIN_UID=2001
CDADMIN_GID=2001
PROXY_URL=NONE
OVERWRITE=N

###############################################################################
# Functions
###############################################################################
#exit Usage
exitUsage() #
{
    cat << EOF
Usage: $0 --node-name node-name --s3-bucket s3-bucket --cd-bin cd-bin --server-keycert server-keycert --secret-key-prefix secret-key-prefix [--efs-dns efs-dns] [--efs-root efs-root] [--aws-region aws-region] [--root-cert root-cert] [--issuing-cert issuing-cert] [--global-folder global-folder] [--local-folder local-folder] [--cdadmin-uid cdadmin-uid] [--cdadmin-gid cdadmin-gid] [--overwrite overwrite] [--proxy-url proxy-url]
    node-name, mandatory; Name of the C:D node e.g. USLDTFCD01
    s3-bucket, mandatory; Name of the S3 bucket from where to pick up the installation resources
    cd-bin, mandatory; Name of the C:D installer ZIP file e.g. IBM_CD_V6.2_UNIX_RedHat.Z.tar.Z
    server-keycert, mandatory; Server keycert file name. e.g. <CN>-keycert.txt
    secret-key-prefix, mandatory; Parameter Store Parameter Key prefix e.g. /aws-tf-cdu/DEV/cdu
    efs-dns, optional; DNS name of the EFS e.g. fs-0ebb56bdc523b3961. If not provided, C:D will be installed on the EBS
    efs-root, optional if efs-dns is not provided; root folder in EFS to mount e.g. /dev/aws-tf-cdu/cdu/USLDCDUC01. If not provided, C:D will be installed on the EBS
    aws-region, optional; AWS Region for the EFS. If not provided, us-east-1 will be assumed
    root-cert, optional; root CA cert file name. If not provided, ca-cert.cer will be assumed
    issuing-cert, optional; issuing CA cert file name. If not provided, issuer-cert.cer will be assumed
    global-folder, optional; global folder to install the C:D software. If not provided /opt/IBM/ConnectDirect will be assumed
    local-folder, optional; local folder to link the global folder to. If not provided /home/cdadmin will be assumed
    cdadmin-uid, optional; POSIX UID for the cdadmin user. default is 2001
    cdadmin-gid, optional; POSIX GID for the cdadmin user. default is 2001
    cw-log-group, optional; CloudWatch log group to send the logs to. If not provided it will not send logs to CW
    overwrite, optional; Y or N; Overwrite existing installation. If not provided it will not overwrite
    proxy-url, optional; If the server is behind a proxy server, provide the URL of the proxy server
EOF
    exit 1
}

# parse arguments
parseArguments()
{
    PARAMS=""
    while (( "$#" )); do
        case "$1" in
            -n|--node-name)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    NODE_NAME=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    exitUsage
                fi
                ;;
            --s3-bucket)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    S3_BUCKET_CD_BINS=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    exitUsage
                fi
                ;;
            --cd-bin)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    IBM_CD_BIN=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    exitUsage
                fi
                ;;
            --secret-key-prefix)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    SECRET_KEY_PREFIX=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    exitUsage
                fi
                ;;
            --efs-dns)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    EFS_DNS=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    exitUsage
                fi
                ;;
            --efs-root)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    EFS_ROOT=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    exitUsage
                fi
                ;;
            --aws-region)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    REGION=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    exitUsage
                fi
                ;;
            --server-keycert)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    SERVER_KEYCERT=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    exitUsage
                fi
                ;;
            --root-cert)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    ROOT_CERT=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    exitUsage
                fi
                ;;
            --issuing-cert)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    ISSUING_CERT=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    exitUsage
                fi
                ;;
            --global-folder)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    GLOBAL_INSTALL_BASE=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    exitUsage
                fi
                ;;
            --local-folder)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    LOCAL_INSTALL_BASE=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    exitUsage
                fi
                ;;
            --cdadmin-uid)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    CDADMIN_UID=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    exitUsage
                fi
                ;;
            --cdadmin-gid)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    CDADMIN_GID=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    exitUsage
                fi
                ;;
            --overwrite)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    OVERWRITE=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    exitUsage
                fi
                ;;
            --cw-log-group)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    CW_LOG_GROUP=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    exitUsage
                fi
                ;;
            --proxy-url)
                if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
                    PROXY_URL=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    exitUsage
                fi
                ;;
            -*|--*=) # unsupported flags
                echo "Error: Unsupported flag $1" >&2
                exitUsage
                ;;
            *) # preserve positional arguments
                PARAMS="$PARAMS $1"
                shift
                ;;
        esac
    done
    # set positional arguments in their proper place
    eval set -- "$PARAMS"
}

# check that needed variables are set
checkVariables() #
{
    if [ -z "$NODE_NAME" ] ; then
        echo "Please provide the CD Node Name e.g. --node-name USLDTFCD01"
        exitUsage
    fi

    if [ -z "$S3_BUCKET_CD_BINS" ] ; then
        echo "Please provide the name of the S3 bucket from where to pick up the installation resources e.g. --s3-bucket some-bucket"
        exitUsage
    fi

    if [ -z "$IBM_CD_BIN" ] ; then
        echo "Please provide the name of the C:D installer ZIP file e.g. --cd-bin IBM_CD_V6.2_UNIX_RedHat.Z.tar.Z"
        exitUsage
    fi

    if [ -z "$SECRET_KEY_PREFIX" ] ; then
        echo "Please provide the Parameter Store Parameter Key prefix e.g. --secret-key-prefix /aws-tf-cdu/DEV/cdu"
        exitUsage
    fi

    if [ -z "$EFS_DNS" ] || [ -z "$EFS_ROOT" ] ; then
        echo "EFS DNS or EFS_ROOT is not provided. Installing on EBS..."
    else
        echo "EFS DNS and EFS_ROOT are provided. Installing on EFS $EFS_DNS $EFS_ROOT..."
        if [ -z "$REGION" ] ; then
            echo "Please provide AWS Region for the EFS e.g. --aws-region us-east-1"
            exitUsage
        fi
    fi

    if [ -z "$SERVER_KEYCERT" ] ; then
        echo "Please provide the server keycert file name e.g. --server-keycert server-keycert.txt"
        exitUsage
    fi

    if [ -z "$ROOT_CERT" ] ; then
        echo "Please provide the root CA cert file name e.g. --root-cert ca-cert.cer"
        exitUsage
    fi

    if [ -z "$ISSUING_CERT" ] ; then
        echo "Please provide the issuing CA cert file name e.g. --issuing-cert issuer-cert.cer"
        exitUsage
    fi

    if [ -z "$GLOBAL_INSTALL_BASE" ] ; then
        echo "Please provide the global folder to install the C:D software e.g. --global-folder /opt/IBM/ConnectDirect"
        exitUsage
    fi

    if [ -z "$LOCAL_INSTALL_BASE" ] ; then
        echo "Please provide the local folder to link the global folder to e.g. --local-folder /home/cdadmin"
        exitUsage
    fi

    if [ -z "$CDADMIN_UID" ] ; then
        echo "Please provide the POSIX UID for the cdadmin user e.g. --cdadmin-uid 2001"
        exitUsage
    fi
    if [ -z "$CDADMIN_GID" ] ; then
        echo "Please provide the POSIX GID for the cdadmin user e.g. --cdadmin-gid 2001"
        exitUsage
    fi

    echo "All variables are set."
    echo "NODE_NAME $NODE_NAME"
    echo "S3_BUCKET_CD_BINS $S3_BUCKET_CD_BINS"
    echo "EFS_DNS $EFS_DNS"
    echo "EFS_ROOT $EFS_ROOT"
    echo "REGION $REGION"
    echo "IBM_CD_BIN $IBM_CD_BIN"
    echo "SERVER_KEYCERT $SERVER_KEYCERT"
    echo "SECRET_KEY_PREFIX $SECRET_KEY_PREFIX"
    echo "ROOT_CERT $ROOT_CERT"
    echo "ISSUING_CERT $ISSUING_CERT"
    echo "GLOBAL_INSTALL_BASE $GLOBAL_INSTALL_BASE"
    echo "LOCAL_INSTALL_BASE $LOCAL_INSTALL_BASE"
    echo "CDADMIN_UID $CDADMIN_UID"
    echo "CDADMIN_GID $CDADMIN_GID"
    echo "PROXY_URL $PROXY_URL"
    echo "CW_LOG_GROUP $CW_LOG_GROUP"
    echo "OVERWRITE $OVERWRITE"
}

# setup proxy, it may be in user data
setupProxy() #
{
    if [ "$PROXY_URL" != "NONE" ] ; then
        # Set Yum HTTP proxy
        if [ ! -f /var/lib/cloud/instance/sem/config_yum_http_proxy ]; then
            echo "proxy=$PROXY_URL" >> /etc/yum.conf
            echo "$$: $(date +%s.%N | cut -b1-13)" > /var/lib/cloud/instance/sem/config_yum_http_proxy
        fi
    fi
}

# add user
addUser() # $1(username) $2(uid) $3(gid)
{
    if id "$1" >/dev/null 2>&1; then
        echo "user $1 exists"
    else
        echo "user $1 does not exist, creating..."
        getent group $3 || groupadd --gid $3 $1
        adduser -u $2 -g $3 $1
        sudo su $1 -c "echo 'export NDMAPICFG=$LOCAL_INSTALL_BASE/cdunix/ndm/cfg/cliapi/ndmapi.cfg' >> /home/$1/.bashrc"
    fi
}

#prep installer
prepInstaller() # S3_BUCKET_CD_BINS, IBM_CD_BIN, NODE_NAME
{
    node_name=$(echo $NODE_NAME | sed -e 's/\(.*\)/\L\1/')
    mkdir -p /tmp/installer
    cd /tmp/installer
    if ! [ -f "$IBM_CD_BIN" ] ; then
        aws s3 cp s3://$S3_BUCKET_CD_BINS/cdu/$IBM_CD_BIN $IBM_CD_BIN
    fi
    aws s3 cp s3://$S3_BUCKET_CD_BINS/cdu/optionsFile.txt optionsFile.txt
    aws s3 cp s3://$S3_BUCKET_CD_BINS/cdu/$NODE_NAME/$ROOT_CERT $ROOT_CERT
    aws s3 cp s3://$S3_BUCKET_CD_BINS/cdu/$NODE_NAME/$ISSUING_CERT $ISSUING_CERT
    aws s3 cp s3://$S3_BUCKET_CD_BINS/cdu/$NODE_NAME/$SERVER_KEYCERT $SERVER_KEYCERT
    #It is OK, if any of these files do not exist
    aws s3 cp s3://$S3_BUCKET_CD_BINS/cdu/$NODE_NAME/initparm.cfg initparm.cfg
    aws s3 cp s3://$S3_BUCKET_CD_BINS/cdu/$NODE_NAME/userfile_a.cfg userfile_a.cfg
    aws s3 cp s3://$S3_BUCKET_CD_BINS/cdu/$NODE_NAME/netmap_a.cfg netmap_a.cfg
    aws s3 cp s3://$S3_BUCKET_CD_BINS/cdu/$NODE_NAME/cdu_extra_files.sh cdu_extra_files.sh
    chmod +x cdu_extra_files.sh

    #Unzip get a tar file
    #unzip $IBM_CD_BIN
    if ! [ -f "cdinstall_a" ] ; then
        tar xvfz $IBM_CD_BIN
    fi
    chmod +x cdinstall
    chmod +x cdinstall_a
    rm -f $IBM_CD_BIN

    #common optionsFile.txt, modify after download
    sed -i "s/^cdai_localNodeName.*$/cdai_localNodeName=$NODE_NAME/" optionsFile.txt
    sed -i "s|^cdai_installDir.*$|cdai_installDir=$GLOBAL_INSTALL_BASE/cdunix|" optionsFile.txt
    sed -i "s/^cdai_localCertFile.*$/cdai_localCertFile=$SERVER_KEYCERT/" optionsFile.txt

    if [ ! -f "userfile_a.cfg" ] ; then
        sed -i "s/^cdai_appendUserFile.*$/#cdai_appendUserFile=userfile_a.cfg/" optionsFile.txt
    fi

    if [ ! -f "netmap_a.cfg" ] ; then
        sed -i "s/^cdai_appendNetmapFile.*$/#cdai_appendNetmapFile=netmap_a.cfg/" optionsFile.txt
    fi

}

# install JQ
installJQ() #
{
    if ! yum list installed jq >/dev/null 2>&1; then
        yum install -y jq
    fi
}

# install CWA
installCWA() #
{
    if [ "$CW_LOG_GROUP" != "" ] ; then
        if ! yum list installed amazon-cloudwatch-agent >/dev/null 2>&1; then
            yum install -y amazon-cloudwatch-agent
        fi
        EC2_INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f 2);
        #configure to only send logs
        aws s3 cp s3://$S3_BUCKET_CD_BINS/cdu/amazon-cloudwatch-agent-logs.json /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-logs.json
        aws s3 cp s3://$S3_BUCKET_CD_BINS/cdu/amazon-cloudwatch-agent-all.json /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-all.json
        sed -i "s/NODE_NAME/$NODE_NAME/g" /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-logs.json
        sed -i "s/NODE_NAME/$NODE_NAME/g" /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-all.json
        #use '|' as sed separator because value contains '/'
        sed -i "s|CW_LOG_GROUP|$CW_LOG_GROUP|g" /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-logs.json
        sed -i "s|CW_LOG_GROUP|$CW_LOG_GROUP|g" /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-all.json
        sed -i "s|EC2_INSTANCE_ID|$EC2_INSTANCE_ID|g" /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-logs.json
        sed -i "s|EC2_INSTANCE_ID|$EC2_INSTANCE_ID|g" /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-all.json
        /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-all.json
    fi
}

createEFSRootFolder() # $1 (/mnt/efs-cd) EFS_ROOT
{
    #Mount at / level and create EFS_ROOT folder if does not exist
    mount -t efs -o tls $EFS_DNS:/ $1
    if df -h | grep -q $1 ; then
        echo "EFS at root is mounted"
    fi

    if [ ! -d "$1$EFS_ROOT" ] ; then
        mkdir -p $1$EFS_ROOT
        echo "Folder $1$EFS_ROOT is created at EFS root"
    else
        echo "Folder $1$EFS_ROOT already exist at EFS root"
    fi

    sleep 5
    umount -f $1

    if ! df -h | grep -q /mnt/efs-cd ; then
        echo "EFS at root is unmounted"
    else
        echo "Error: EFS at root is still mounted"
    fi
    sleep 15
}

#prep EFS
prepEFS() # NODE_NAME EFS_DNS EFS_ROOT REGION
{
    if ! df -h | grep -q /mnt/efs-cd ; then
        echo "EFS is not mounted"

        #install amazon-efs-utils
        if ! yum list installed amazon-efs-utils >/dev/null 2>&1; then
            echo "amazon-efs-utils is not installed. Installing..."
            yum install -y amazon-efs-utils
        fi

        if [ "$CW_LOG_GROUP" != "" ] ; then
            #modify /etc/amazon/efs/efs-utils.conf to enable CloudWatch monitoring
            grep -A1 '\[cloudwatch-log\]' /etc/amazon/efs/efs-utils.conf | grep '^#.*enabled = true' && sed -i '/^\[cloudwatch-log\]/a enabled = true' /etc/amazon/efs/efs-utils.conf
            echo "Enabled cloudwatch monitoring for EFS"
        fi

        #install botocore, EFS monitoring uses botocore
        if [ "$PROXY_URL" != "NONE" ] ; then
            pip3 install botocore --upgrade --proxy $PROXY_URL
        else
            pip3 install botocore --upgrade
        fi

        mkdir -p /mnt/efs-cd

        #echo "mount -t efs -o tls,iam,accesspoint=$EFS_AP_ID $EFS_DNS:/ /mnt/efs-cd"
        #mount -t efs -o tls,iam,accesspoint=$EFS_AP_ID $EFS_DNS:/ /mnt/efs-cd
        echo "mount -t efs -o tls,iam $EFS_DNS:$EFS_ROOT /mnt/efs-cd"
        mount -t efs -o tls,iam $EFS_DNS:$EFS_ROOT /mnt/efs-cd

        echo "checking EFS should be mounted"
        if df -h | grep -q "127.0.0.1:$EFS_ROOT" ; then
            echo "EFS at $EFS_ROOT is mounted"
        else
            echo "EFS at $EFS_ROOT is not mounted, creating $EFS_ROOT folder"
            createEFSRootFolder "/mnt/efs-cd"
            #try mounting after creating folder
            echo "mount -t efs -o tls,iam $EFS_DNS:$EFS_ROOT /mnt/efs-cd"
            mount -t efs -o tls,iam $EFS_DNS:$EFS_ROOT /mnt/efs-cd

            echo "checking EFS should be mounted"
            if df -h | grep -q "127.0.0.1:$EFS_ROOT" ; then
                echo "EFS at $EFS_ROOT is mounted"
            fi
        fi

        #modify /etc/fstab to auto mount EFS
        #grep -q efs-cd /etc/fstab || echo "$EFS_DNS:/ /mnt/efs-cd efs _netdev,noresvport,tls,iam,accesspoint=$EFS_AP_ID 0 0" >> /etc/fstab
        grep -q efs-cd /etc/fstab || echo "$EFS_DNS:$EFS_ROOT /mnt/efs-cd efs _netdev,noresvport,tls,iam 0 0" >> /etc/fstab
        echo "Enabled EFS to mount on start via fstab"
    fi

    #create folder for the C:D node (just in case same EFS is used for multiple C:D nodes)
    mkdir -p /mnt/efs-cd/$NODE_NAME/cdunix
    chown cdadmin:cdadmin /mnt/efs-cd/$NODE_NAME

    mkdir -p $GLOBAL_INSTALL_BASE

    #Existing cdunix in case of EBS or stop/start
    if [[ -L "$GLOBAL_INSTALL_BASE/cdunix" ]]; then
        unlink $GLOBAL_INSTALL_BASE/cdunix
        ln -s /mnt/efs-cd/$NODE_NAME/cdunix $GLOBAL_INSTALL_BASE/cdunix
    else
        ln -s /mnt/efs-cd/$NODE_NAME/cdunix $GLOBAL_INSTALL_BASE/cdunix
    fi

    if [[ "$OVERWRITE" == "Y" ]] ; then
        echo "Overwriting existing install"
        curDate=`date +%Y%m%d%H%M%S`
        #create folder on EBS
        mkdir -p $GLOBAL_INSTALL_BASE/cdunix.bu.$curDate
        #move existing install from EFS/EBS to EBS
        mv -f $GLOBAL_INSTALL_BASE/cdunix/* $GLOBAL_INSTALL_BASE/cdunix.bu.$curDate
        #ln -s /mnt/efs-cd/$NODE_NAME/cdunix $GLOBAL_INSTALL_BASE/cdunix
        #rm -rf $GLOBAL_INSTALL_BASE/cdunix/*
    fi

    #mkdir -p $GLOBAL_INSTALL_BASE/cdunix/deployDir
    chown cdadmin:cdadmin $GLOBAL_INSTALL_BASE/cdunix

    #debug
    ls -la $GLOBAL_INSTALL_BASE
    ls -la /mnt/efs-cd/$NODE_NAME

    #symlink for cdadmin from GLOBAL to LOCAL
    sudo su cdadmin -c "ln -sf $GLOBAL_INSTALL_BASE/cdunix $LOCAL_INSTALL_BASE/cdunix"
}

#prep EBS, if EFS is not used, use EBS
prepEBS() # NODE_NAME
{
    mkdir -p $GLOBAL_INSTALL_BASE
    if [ -d "$GLOBAL_INSTALL_BASE/cdunix" ] ; then
        if [[ "$OVERWRITE" = "Y" ]] ; then
            curDate=`date +%Y%m%d%H%M%S`
            mv -f $GLOBAL_INSTALL_BASE/cdunix $GLOBAL_INSTALL_BASE/cdunix.bu.$curDate
            mkdir -p $GLOBAL_INSTALL_BASE/cdunix
        else
            if [[ -L "$GLOBAL_INSTALL_BASE/cdunix" ]]; then
                unlink $GLOBAL_INSTALL_BASE/cdunix
                mkdir -p $GLOBAL_INSTALL_BASE/cdunix
            fi
        fi
    else
        mkdir -p $GLOBAL_INSTALL_BASE/cdunix
    fi

    #mkdir -p $GLOBAL_INSTALL_BASE/cdunix/deployDir
    chown cdadmin:cdadmin $GLOBAL_INSTALL_BASE/cdunix

    #debug
    ls -la $GLOBAL_INSTALL_BASE

    #symlink for cdadmin from GLOBAL to LOCAL
    sudo su cdadmin -c "ln -sf $GLOBAL_INSTALL_BASE/cdunix $LOCAL_INSTALL_BASE/cdunix"
}

#setup SystemCtl Service
setupSystemCtlService() # NODE_NAME
{
    INITPARM=$LOCAL_INSTALL_BASE/cdunix/ndm/cfg/$NODE_NAME/initparm.cfg

    cat << EOF > /etc/systemd/system/cd-svr.service
[Unit]
Description=Connect:Direct Server
After=network.target remote-fs.target

[Service]
Type=forking
User=cdadmin
ExecStart=$LOCAL_INSTALL_BASE/cdunix/ndm/bin/cdpmgr -i $INITPARM
ExecStop=/usr/bin/echo "stop ;" | $LOCAL_INSTALL_BASE/cdunix/ndm/bin/direct

[Install]
WantedBy=multi-user.target
EOF

    systemctl enable cd-svr.service
    systemctl daemon-reload
}

# install CD
installCD() #
{
    cd /tmp/installer
    CERT_PWD=`aws ssm get-parameter --region ${REGION} --with-decryption --name ${SECRET_KEY_PREFIX}/${NODE_NAME}/cert_password  | jq -r .Parameter.Value`
    KEYSTORE_PWD=`aws ssm get-parameter --region ${REGION} --with-decryption --name ${SECRET_KEY_PREFIX}/${NODE_NAME}/keystore_password  | jq -r .Parameter.Value`
    echo "Installing C:D in $GLOBAL_INSTALL_BASE. Check the progress via, tail -f /tmp/installer/cdaiLog.txt"
    ./cdinstall_a -f optionsFile.txt --localCertPassphrase $CERT_PWD --keystorePassword $KEYSTORE_PWD
}

# setupConfig, modify the default config files
setupConfig() #
{
    sudo su cdadmin -c "sed -i 's/^ :tcp.hostname.*$/ :tcp.hostname=0.0.0.0:\\\/' $LOCAL_INSTALL_BASE/cdunix/ndm/cfg/cliapi/ndmapi.cfg"
    #modify initparm.cfg comm.info
    sudo su cdadmin -c "sed -i 's/^ :comm.info.*$/ :comm.info=0.0.0.0;1364:\\\/' $LOCAL_INSTALL_BASE/cdunix/ndm/cfg/$NODE_NAME/initparm.cfg"

    sudo su cdadmin -c "sed -i 's/^ :comm.info=ip-.*$/ :comm.info=0.0.0.0;1364:\\\/' $LOCAL_INSTALL_BASE/cdunix/ndm/cfg/$NODE_NAME/netmap.cfg"
    sudo su cdadmin -c "sed -i 's/^ :tcp.api=.*;1363.*$/ :tcp.api=0.0.0.0;1363:\\\/' $LOCAL_INSTALL_BASE/cdunix/ndm/cfg/$NODE_NAME/netmap.cfg"


    #Copy test files
    #sudo su cdadmin -c "aws s3 cp s3://$S3_BUCKET_CD_BINS/cdu/$NODE_NAME/test.txt $LOCAL_INSTALL_BASE/cdunix/ndm/bin/test.txt"

    if [ -f "cdu_extra_files.sh" ] ; then
        chmod +x cdu_extra_files.sh
        ./cdu_extra_files.sh
    fi

}

# stopInstalledServer
stopInstalledServer() # LOCAL_INSTALL_BASE
{
    sudo su cdadmin -c "export NDMAPICFG=$LOCAL_INSTALL_BASE/cdunix/ndm/cfg/cliapi/ndmapi.cfg ; echo 'stop ; ' | $LOCAL_INSTALL_BASE/cdunix/ndm/bin/direct"
    #stop File Agent
    $GLOBAL_INSTALL_BASE/cdunix/install/agent/bin/stopAgent.sh
}

# setup auto start
setupAutoStart() # LOCAL_INSTALL_BASE
{
    setupSystemCtlService
    #stop server
    systemctl stop cd-svr
    systemctl start cd-svr
    systemctl status cd-svr
}

# sync netmap
execSPConfig() # LOCAL_INSTALL_BASE
{
    cat << EOD > /tmp/installer/spConfig.txt
sync netmap
path=$LOCAL_INSTALL_BASE/cdunix/ndm/cfg/$NODE_NAME/netmap.cfg
name=*
;
update localnode
Override=Y
;
q
;
EOD
    sudo su cdadmin -c "$LOCAL_INSTALL_BASE/cdunix/ndm/bin/spcli.sh < /tmp/installer/spConfig.txt"
    echo
}

###############################################################################
# Main
###############################################################################

#parse arguments, exit if invalid arguments
parseArguments $@

#check variables, exit if mandatory are missing
checkVariables

#exit if not root user
if (( $EUID != 0 )); then
   echo "You must run this script as root" 1>&2
   exit 1
fi

#prevent installation, if alredy exist
#This can happen only when you run this script during reboot
if [ -d "$GLOBAL_INSTALL_BASE/cdunix/ndm/cfg/$NODE_NAME" ]; then
    echo "C:D is already installed for $NODE_NAME"
    exit 0
fi

#setup proxy
setupProxy

#install JQ
installJQ

#install CWA
installCWA

#add Users
addUser cdadmin $CDADMIN_UID $CDADMIN_GID
#addUser cduserin 2002 2002
#addUser cduserout 2003 2003

if [ -z "$EFS_DNS" ] || [ -z "$EFS_ROOT" ]; then
    prepEBS
else
    prepEFS
fi

#prevent installation, if alredy exist, via EFS mount
if [ -d "$GLOBAL_INSTALL_BASE/cdunix/ndm/cfg/$NODE_NAME" ]; then
    echo "C:D is already installed for $NODE_NAME"
else
    # get installation resources from S3
    prepInstaller

    # install Cd
    installCD

    if grep -q "MSGID=CDAI001I" /tmp/installer/exitStatusFile.txt ; then
        echo "C:D installation successful."
        #other spCLI scripts
        execSPConfig
        stopInstalledServer
    else
        echo "C:D installation failed. Check /tmp/installer/cdaiLog.txt"
        exit 1
    fi
fi

#setup every time to pull in latest changes
setupConfig

setupAutoStart

echo "C:D installation/configuration/auto-start successful."

exit 0
