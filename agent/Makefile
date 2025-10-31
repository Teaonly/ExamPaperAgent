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
$(file >$(_DIR_)/考试要求.txt, $(EXAMP_REQUIREMENT))

## 第一任务触发工作流
.PHONY: clean 
all: $(_DIR_)/试卷.docx
clean:
	@rm -f out/*

.ONESHELL: $(_DIR_)/考点.txt
$(_DIR_)/考点.txt:
	@echo "请输入课程名称："
	@read -p "=> " COURSE_NAME
	@if [ -z "$$COURSE_NAME" ]; then echo "谢谢使用！"; exit ; fi
	
	$(_IFL_) -t "请生成 $$COURSE_NAME 相关考试考点表，考点略微详细一点，按两层章节罗列，文件中包含科目名称，知识点考察点文件保存为 '考点.txt'"
	mv 考点.txt $(_DIR_)/

.ONESHELL: $(_DIR_)/单选题.json
$(_DIR_)/单选题.json: $(_DIR_)/考点.txt
	$(_IFL_) -i $(_DIR_)/考试要求.txt $^ -t " 请相关根据要求完成单选题的题目设计，出题请包含答案，使用JSON格式输出，保存为 '单选题.json' 文件"
	mv 单选题.json $(_DIR_)/单选题.json

.ONESHELL: $(_DIR_)/判断题.json 
$(_DIR_)/判断题.json: $(_DIR_)/考点.txt 
	$(_IFL_) -i $(_DIR_)/考试要求.txt $^  -t " 请相关根据要求完成判断题的题目设计，出题请包含答案，使用JSON格式输出，保存为 '判断题.json' 文件"
	mv 判断题.json $(_DIR_)/判断题.json

.ONESHELL: $(_DIR_)/填空题.json 
$(_DIR_)/填空题.json: $(_DIR_)/考点.txt 
	$(_IFL_) -i $(_DIR_)/考试要求.txt $^ -t " 请相关根据要求完成填空题的题目设计，出题请包含答案，使用JSON格式输出，保存为 '填空题.json' 文件"
	mv 填空题.json $(_DIR_)/填空题.json

.ONESHELL: $(_DIR_)/名词解释题.json 
$(_DIR_)/名词解释题.json: $(_DIR_)/考点.txt 
	$(_IFL_) -i $(_DIR_)/考试要求.txt $^ -t " 请相关根据要求完成名词解释的题目设计，出题请包含答案，使用JSON格式输出，保存为 '名词解释题.json' 文件"
	mv 名词解释题.json $(_DIR_)/名词解释题.json

.ONESHELL: $(_DIR_)/问答计算题.json 
$(_DIR_)/问答计算题.json: $(_DIR_)/考点.txt 
	$(_IFL_) -i $(_DIR_)/考试要求.txt $^ -t " 请相关根据要求完成问答计算题的题目设计，出题请包含答案，使用JSON格式输出，保存为 '问答计算题.json' 文件"
	mv 问答计算题.json $(_DIR_)/问答计算题.json

$(_DIR_)/试卷.docx: $(_DIR_)/考点.txt $(_DIR_)/单选题.json $(_DIR_)/判断题.json  $(_DIR_)/填空题.json $(_DIR_)/名词解释题.json $(_DIR_)/问答计算题.json 
	@echo "开始生成Word文件..."
	$(_IFL_) -i $(_DIR_)/考点.txt $(_DIR_)/考试要求.txt -t "根据相关信息，输出Word（docx格式）试卷的Python生成代码，采用Pyhton语言，使用python-docx库，当前仅需要输出试卷的空白格式，代码保存在 gen.py 文件"

