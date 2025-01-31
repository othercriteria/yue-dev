YUE_REPO = https://github.com/multimodal-art-projection/YuE.git
YUE_COMMIT = 493478202e635c019bfe68ff9fbcdc94ba092f8f
XCODEC_REPO = https://huggingface.co/m-a-p/xcodec_mini_infer
XCODEC_COMMIT = fe781a67815ab47b4a3a5fce1e8d0a692da7e4e5

.PHONY: setup clean demo

setup: YuE/inference/xcodec_mini_infer

YuE:
	git clone $(YUE_REPO)
	cd YuE && git checkout $(YUE_COMMIT)

YuE/inference/xcodec_mini_infer: YuE
	cd YuE/inference && git clone $(XCODEC_REPO)
	cd YuE/inference/xcodec_mini_infer && git checkout $(XCODEC_COMMIT)

clean:
	rm -rf .venv
	rm -rf YuE 
	rm -rf .micromamba

demo:
	cd YuE/inference/ && \
	python infer.py \
    --stage1_model m-a-p/YuE-s1-7B-anneal-en-cot \
    --stage2_model m-a-p/YuE-s2-1B-general \
    --genre_txt ../../genre.txt \
    --lyrics_txt ../../lyrics.txt \
    --run_n_segments 2 \
    --stage2_batch_size 4 \
    --output_dir ../../output \
    --cuda_idx 0 \
    --max_new_tokens 3000
