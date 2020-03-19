for i in $(find . -type d | grep '/' | sed 's|\./||')
do
cat << EOF > "${MODCELLHPC_S_PATH}/runs/partitions/${i}/case_info.tsv"
\${MODCELLHPC_S_PATH}/cases/${i}/
EOF
done

