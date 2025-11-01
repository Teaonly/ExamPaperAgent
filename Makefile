_DIR_ := ./out
$(shell mkdir -p $(_DIR_))
_IFL_ = ifl -y -s ./config_exam.yaml 

## 内置提示词
define EXAMP_REQUIREMENT
试题要求，整套试卷包括：10 道单选题（20分），10 道判断题（10分），填空题10个空（20分），5 道名词解释题目（10分）, 4道问答计算题（40分）。
出题要求：
* 同样的知识点，考察不要超过两次
* 考题分布尽量平均，各章节都涉及到
* 考点.txt 为需要考试内容
* 每个题型独立出题
endef
export EXAMP_REQUIREMENT



## 第一任务触发工作流
.PHONY: clean 
all: $(_DIR_)/试卷.docx
clean:
	@rm -f out/*
	@rm -f in.docx out.docx

$(_DIR_)/考试要求.txt:
	@echo  "生成考试要求..."
	$(file >$(_DIR_)/考试要求.txt, $(EXAMP_REQUIREMENT))

.ONESHELL: $(_DIR_)/考点.txt
$(_DIR_)/考点.txt: $(_DIR_)/考试要求.txt
	@echo "请输入课程名称："
	@read -p "=> " COURSE_NAME	 
	@if [ -z "$$COURSE_NAME" ]; then echo "谢谢使用！"; exit 1; fi 
	$(_IFL_) -t "请生成 $$COURSE_NAME 相关考试的考点表，考点略微详细一点，按两层章节罗列，文件中包含科目名称，考点表文件保存为 '考点.txt'" 
	mv 考点.txt $(_DIR_)/

$(_DIR_)/%.json: $(_DIR_)/考点.txt
	$(_IFL_) -i $(_DIR_)/考试要求.txt $^ -t " 请相关要求完 $* 题目设计，出题请包含答案，使用JSON格式输出，保存为 '$*.json' 文件"
	@mv $*.json $@

$(_DIR_)/试卷_单选题.docx: $(_DIR_)/单选题.json
	@rm -f in.docx out.docx gen.py run_error
	@cp template.docx in.docx
	@make -f gen.mk TOPIC="单选题"
	@mv out.docx $@
	@rm -f in.docx out.docx gen.py run_error

$(_DIR_)/试卷_判断题.docx: $(_DIR_)/判断题.json $(_DIR_)/试卷_单选题.docx
	@rm -f in.docx out.docx $(_DIR_)/gen.py run_error
	@cp $(_DIR_)/试卷_单选题.docx in.docx
	@make -f gen.mk TOPIC="判断题"
	@mv out.docx $@
	@rm -f in.docx out.docx $(_DIR_)/gen.py run_error

$(_DIR_)/试卷.docx: $(_DIR_)/试卷_单选题.docx
