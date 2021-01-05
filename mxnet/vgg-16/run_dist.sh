export dmlc_num_server=1
export dmlc_num_worker=1
export nvidia_visible_devices=0,1,2,3
export distributed_framework=byteps
export byteps_server_enable_schedule=1
export byteps_scheduling_credit=8000000
export byteps_partition_bytes=4096000
export dmlc_ps_root_uri=172.31.93.148
export COMMAND='python3 /home/cluster/byteps/examples/mxnet/vgg-16/train_imagenet.py --network vgg --num-layers 16 --batch-size 32 --benchmark 1 --num-examples 3232 --num-epochs 1 --disp-batches 10'

# scheduler
DMLC_ROLE=scheduler DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker NVIDIA_VISIBLE_DEVICES=$nvidia_visible_devices DISTRIBUTED_FRAMEWORK=$distributed_framework BYTEPS_SERVER_ENABLE_SCHEDULE=$byteps_server_enable_schedule BYTEPS_SCHEDULING_CREDIT=$byteps_scheduling_credit BYTEPS_PARTITION_BYTES=$byteps_partition_bytes DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000  bpslaunch &

# server
ssh cluster@172.31.93.148 "DMLC_ROLE=server DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker NVIDIA_VISIBLE_DEVICES=$nvidia_visible_devices DISTRIBUTED_FRAMEWORK=$distributed_framework BYTEPS_SERVER_ENABLE_SCHEDULE=$byteps_server_enable_schedule BYTEPS_SCHEDULING_CREDIT=$byteps_scheduling_credit BYTEPS_PARTITION_BYTES=$byteps_partition_bytes DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000  bpslaunch &" &


# worker
ssh cluster@172.31.93.148 "DMLC_WORKER_ID=0 DMLC_ROLE=worker DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker NVIDIA_VISIBLE_DEVICES=$nvidia_visible_devices DISTRIBUTED_FRAMEWORK=$distributed_framework BYTEPS_SERVER_ENABLE_SCHEDULE=$byteps_server_enable_schedule BYTEPS_SCHEDULING_CREDIT=$byteps_scheduling_credit BYTEPS_PARTITION_BYTES=$byteps_partition_bytes DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 bpslaunch $COMMAND >/home/cluster/byteps/examples/mxnet/vgg-16/test.txt 2>&1 &" &
