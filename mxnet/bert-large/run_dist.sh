#!/bin/bash

# below params are used in V100-32GB, with synthetic data
export OPTIONS=--synthetic_data\ --eval_use_npz;
export TRUNCATE_NORM="${TRUNCATE_NORM:-1}"
export LAMB_BULK="${LAMB_BULK:-30}"
export EPS_AFTER_SQRT="${EPS_AFTER_SQRT:-1}"
export NUMSTEPS="${NUMSTEPS:-281250}"
export DTYPE="${DTYPE:-float16}"
export ACC="${ACC:-1}"
export MODEL="${MODEL:-bert_24_1024_16}"
export MAX_SEQ_LENGTH="${MAX_SEQ_LENGTH:-128}"
export MAX_PREDICTIONS_PER_SEQ="${MAX_PREDICTIONS_PER_SEQ:-20}"
export LR="${LR:-0.00354}"
export LOGINTERVAL="${LOGINTERVAL:-10}"
export CKPTDIR="${CKPTDIR:-ckpt_stage1_lamb_16k-682a361-c5fd6fc-0412-cu90}"
export CKPTINTERVAL="${CKPTINTERVAL:-300000000}"
export OPTIMIZER="${OPTIMIZER:-bertadam}"
export WARMUP_RATIO="${WARMUP_RATIO:-0.1}"
export MXNET_EXEC_BULK_EXEC_MAX_NODE_TRAIN_FWD="${MXNET_EXEC_BULK_EXEC_MAX_NODE_TRAIN_FWD:-120}"
export MXNET_EXEC_BULK_EXEC_MAX_NODE_TRAIN_BWD="${MXNET_EXEC_BULK_EXEC_MAX_NODE_TRAIN_BWD:-120}"
export MXNET_SAFE_ACCUMULATION="${MXNET_SAFE_ACCUMULATION:-1}"
export DATA="${DATA:-/data/book-corpus/book-corpus-large-split/*.train,/data/enwiki/enwiki-feb-doc-split/*.train}"
export DATAEVAL="${DATAEVAL:-/data/book-corpus/book-corpus-large-split/*.test,/data/enwiki/enwiki-feb-doc-split/*.test}"
export BATCH_SIZE_PER_GPU=${BATCH_SIZE_PER_GPU:-2} #64
export NUM_GPU=${NUM_GPU:-1} #8
export TOTAL_BATCH_SIZE=$(($NUM_GPU*$BATCH_SIZE_PER_GPU))

export COMM_BACKEND=${COMM_BACKEND:-byteps}

export dmlc_num_server=1
export dmlc_num_worker=1
export nvidia_visible_devices=0
export distributed_framework=byteps

#schedule
#export byteps_server_enable_schedule=1
#export byteps_scheduling_credit=4
#no-schedule
export byteps_server_enable_schedule=0
# partition
export byteps_partition_bytes=4096000
#no-partition
#export byteps_partition_bytes=480000000

export dmlc_ps_root_uri=172.31.90.52
export byteps_trace_on=0
export byteps_trace_dir=/home/cluster/byteps/examples/mxnet/bert-large
#export COMMAND='python3 gluon-nlp/scripts/bert/run_pretraining.py --data=$DATA --data_eval=$DATAEVAL --optimizer $OPTIMIZER --warmup_ratio $WARMUP_RATIO --num_steps $NUMSTEPS --ckpt_interval $CKPTINTERVAL --dtype $DTYPE --ckpt_dir $CKPTDIR --lr $LR --accumulate $ACC --model $MODEL --max_seq_length $MAX_SEQ_LENGTH --max_predictions_per_seq $MAX_PREDICTIONS_PER_SEQ --num_data_workers 4 --no_compute_acc --comm_backend $COMM_BACKEND --log_interval $LOGINTERVAL --total_batch_size $TOTAL_BATCH_SIZE --total_batch_size_eval $TOTAL_BATCH_SIZE $OPTIONS'


# scheduler
BYTEPS_TRACE_ON=$byteps_trace_on BYTEPS_TRACE_END_STEP=20 BYTEPS_TRACE_START_STEP=10 BYTEPS_TRACE_DIR=$byteps_trace_dir DMLC_ROLE=scheduler DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker NVIDIA_VISIBLE_DEVICES=$nvidia_visible_devices DISTRIBUTED_FRAMEWORK=$distributed_framework BYTEPS_SERVER_ENABLE_SCHEDULE=$byteps_server_enable_schedule BYTEPS_SCHEDULING_CREDIT=$byteps_scheduling_credit BYTEPS_PARTITION_BYTES=$byteps_partition_bytes DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000  bpslaunch &

# server
ssh cluster@172.31.90.52 "BYTEPS_TRACE_ON=$byteps_trace_on BYTEPS_TRACE_END_STEP=20 BYTEPS_TRACE_START_STEP=10 BYTEPS_TRACE_DIR=$byteps_trace_dir DMLC_ROLE=server DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker NVIDIA_VISIBLE_DEVICES=$nvidia_visible_devices DISTRIBUTED_FRAMEWORK=$distributed_framework BYTEPS_SERVER_ENABLE_SCHEDULE=$byteps_server_enable_schedule BYTEPS_SCHEDULING_CREDIT=$byteps_scheduling_credit BYTEPS_PARTITION_BYTES=$byteps_partition_bytes DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000  bpslaunch &" &

# worker
ssh cluster@172.31.90.52 "cd $byteps_trace_dir;BYTEPS_TRACE_ON=$byteps_trace_on BYTEPS_TRACE_END_STEP=20 BYTEPS_TRACE_START_STEP=10 BYTEPS_TRACE_DIR=$byteps_trace_dir DMLC_WORKER_ID=0 DMLC_ROLE=worker DMLC_NUM_SERVER=$dmlc_num_server DMLC_NUM_WORKER=$dmlc_num_worker NVIDIA_VISIBLE_DEVICES=$nvidia_visible_devices DISTRIBUTED_FRAMEWORK=$distributed_framework BYTEPS_SERVER_ENABLE_SCHEDULE=$byteps_server_enable_schedule BYTEPS_SCHEDULING_CREDIT=$byteps_scheduling_credit BYTEPS_PARTITION_BYTES=$byteps_partition_bytes DMLC_PS_ROOT_URI=$dmlc_ps_root_uri DMLC_PS_ROOT_PORT=8000 bpslaunch python3 gluon-nlp/scripts/bert/run_pretraining.py --data=$DATA --data_eval=$DATAEVAL --optimizer $OPTIMIZER --warmup_ratio $WARMUP_RATIO --num_steps $NUMSTEPS --ckpt_interval $CKPTINTERVAL --dtype $DTYPE --ckpt_dir $CKPTDIR --lr $LR --accumulate $ACC --model $MODEL --max_seq_length $MAX_SEQ_LENGTH --max_predictions_per_seq $MAX_PREDICTIONS_PER_SEQ --num_data_workers 4 --no_compute_acc --comm_backend $COMM_BACKEND --log_interval $LOGINTERVAL --total_batch_size $TOTAL_BATCH_SIZE --total_batch_size_eval $TOTAL_BATCH_SIZE $OPTIONS >/home/cluster/byteps/examples/mxnet/bert-large/test.txt 2>&1 &" &
 #>/home/cluster/byteps/examples/mxnet/bert-large/test.txt 2>&1 &

