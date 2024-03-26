#!/bin/bash

set -e

ANSIBLE_USER=${ANSIBLE_USER:-ansible}
if [[ -z "$PUBLIC_KEY" ]]; then
    [[ -z "$GH_USERNAME" ]] && echo "Please set GH_USERNAME" && exit 1
    PUBLIC_KEY="$(curl -sfL https://github.com/$GH_USERNAME.keys)"
fi

# Create an ansible user
if id $ANSIBLE_USER 2>&1 &>/dev/null; then
    echo "$ANSIBLE_USER already exists"
else
    echo "$ANSIBLE_USER doesn't exist. Creating it..."
    useradd -mG sudo $ANSIBLE_USER
fi

# Allow the user to sudo without password
if [[ ! -f "/etc/sudoers.d/99-ansible" ]]; then
    echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/99-ansible
    chmod 440 /etc/sudoers.d/99-ansible
fi

# Ensure ssh directory exists and add public keys into ~/.ssh/authorized_keys to login from your computer.
ssh_dir=/home/$ANSIBLE_USER/.ssh
mkdir -p $ssh_dir
chmod 700 $ssh_dir
chown $ANSIBLE_USER: $ssh_dir

cat <<EOF

The following public keys will be added to $ssh_dir/authorized_keys
- - - - - - - - - -
$PUBLIC_KEY
- - - - - - - - - -

EOF

touch ${ssh_dir}/authorized_keys
chown $ANSIBLE_USER: ${ssh_dir}/authorized_keys
echo "$PUBLIC_KEY" | while read k; do
    if ! grep "$k" ${ssh_dir}/authorized_keys >/dev/null; then
        echo "$k" >> ${ssh_dir}/authorized_keys
    fi
done

echo "Done"
