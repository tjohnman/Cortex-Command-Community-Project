jitlib_files = files('bc.lua', 'v.lua', 'dump.lua', 'dis_x86.lua', 'dis_x64.lua', 'dis_arm.lua', 'dis_ppc.lua', 'dis_mips.lua', 'dis_mipsel.lua', 'bcsave.lua')

if get_option('app')
  install_data(jitlib_files, install_dir: jitlib_install_dir)
endif
