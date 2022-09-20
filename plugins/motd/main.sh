import plugins/motd/motd
((${+__blck_opts[motd-file]})) && print-motd $__blck_opts[motd-file]