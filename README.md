apt update

apt upgrade -y

apt install -y curl

curl -fsSL https://raw.githubusercontent.com/davigalucio/linux/main/debian_repository.sh | sh

curl -fsSL https://raw.githubusercontent.com/davigalucio/linux/main/essentials.sh | sh

curl -fsSL https://raw.githubusercontent.com/davigalucio/linux/main/xpra.sh | sh
