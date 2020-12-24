sims=(/bin/lif_unit_test) # bsim ngpu (all sims)
gpus=("0" "0,1" "0,1,2,3" "0,1,2,3,4,5,6,7")
gpu=("single" "multi" "multi" "multi")
sizes=({200000000..2000000000..200000000})

echo "[" > results.json

run() {
	echo $1
	eval "$1 >> results.json"
	echo -n "," >> results.json
}

for sim in ${sims[@]}
do
	export CUDA_VISIBLE_DEVICES=0
	
	# simtime sparse
	for size in ${sizes[@]}
	do
		run ".$sim --bench sim --gpu single --model synth --pconnect 0.00156 --pfire 0.005 --delay 1 --nsyn $size"
	done

	for igpu in {0..3}
	do
		export CUDA_VISIBLE_DEVICES=${gpus[$igpu]}

		# simtime
		for model in vogels brunel
		do
			for size in ${sizes[@]}
			do
				run ".$sim --bench sim --gpu ${gpu[$igpu]} --model $model --nsyn $size"
			done
		done

		# setup time
		for size in ${sizes[@]}
		do
			run ".$sim --bench setup --gpu ${gpu[$igpu]} --model synth --pconnect 0.05 --pfire 0.001 --delay 1 --nsyn $size"
		done
	done
done

# TODO: speedup (as function of delay) (metrics, viz, ..)

echo -n "{}]" >> results.json
