export STORAGE_PATH=/srv/docker/dcc
export DCC_INSTANCE=seaview.phy.syr.edu
export DCC_HOSTNAME=seaview.phy.syr.edu
export DCC_DOMAINNAME=phy.syr.edu
export HYDRA_PASSWD=aghitsasnake

echo "Enter SECRETS_SYSTEM generated by dcc-bootstrap.sh"
read RESPONSE
if test "x${RESPONSE}" == "x" ; then
  echo "Error: no secret specified"
  kill -INT $$
fi
export SECRETS_SYSTEM=${RESPONSE}
