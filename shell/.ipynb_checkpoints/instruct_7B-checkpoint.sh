echo $1, $2
seed=$2
output_dir='./test'
base_model='baffo32/decapoda-research-llama-7B-hf'
train_data='./data/book/train_small.json'
val_data='./data/book/valid.json'
instruction_model='chainyo/alpaca-lora-7b'

# Define the number of lines to extract
number_of_lines=100  # Adjust this to the desired number of lines

# Extract a subset of the train_data JSON file
head -n "$number_of_lines" "$train_data" > subset_train_data.json

for lr in 1e-4
do
    for dropout in 0.05
    do
        for sample in 64
        do
                mkdir -p $output_dir
                echo "lr: $lr, dropout: $dropout , seed: $seed, sample: $sample"
                CUDA_VISIBLE_DEVICES=$1 python -u finetune_rec.py \
                    --base_model $base_model \
                    --train_data_path $train_data \
                    --val_data_path $val_data \
                    --output_dir ${output_dir}_${seed}_${sample} \
                    --batch_size 128 \
                    --micro_batch_size 32 \
                    --num_epochs 200 \
                    --learning_rate $lr \
                    --cutoff_len 512 \
                    --lora_r 8 \
                    --lora_alpha 16\
                    --lora_dropout $dropout \
                    --lora_target_modules '[q_proj,v_proj]' \
                    --train_on_inputs \
                    --group_by_length \
                    --resume_from_checkpoint $instruction_model \
                    --sample $sample \
                    --seed $2
        done
    done
done

