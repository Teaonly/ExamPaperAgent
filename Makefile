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

define GENCODE_PROMPT
基于 Python ，采用 python-docx 库，输出 编辑考试试卷 word 文件的代码。

参考功能代码，需要完成下面 TODO 内容

```
import json
from docx import Document

# 读取JSON试题数据，TODO 根据用户输入调整
with open('./out/试题.json', 'r', encoding='utf-8') as f:
    questions = json.load(f)

# 内容采用追加形式，从 'in.docx' 输入，这部分不要动
doc = Document('in.docx')

# 添加标题，TODO 根据JSON 生成合适的标题
doc.add_heading('试题标题', level=1)

# 遍历试题并文档添加题目内容
for i, q in enumerate(questions, 1):
	## TODO 需要根据用户输入 JSON格式，输出题目内容到 out.docx

# 保存到输出文件
doc.save('out.docx')

```

根据参考代码，生成新代码文件 gen.py 

endef
export GENCODE_PROMPT

## 第一任务触发工作流
.PHONY: clean 
all: $(_DIR_)/试卷.docx
clean:
	@rm -f out/*

$(_DIR_)/考试要求.txt:
	@echo  "生成考试要求..."
	$(file >$(_DIR_)/考试要求.txt, $(EXAMP_REQUIREMENT))

.ONESHELL: $(_DIR_)/考点.txt
$(_DIR_)/考点.txt: $(_DIR_)/考试要求.txt:
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

$(_DIR_)/试卷_P1.docx: $(_DIR_)/单选题.json
	@cp template.docx in.docx
	$(file >$(_DIR_)/_.txt, $(GENCODE_PROMPT))
	$(_IFL_) -i $(_DIR_)/单选题.json $^ -ti $(_DIR_)/_.txt

$(_DIR_)/试卷.docx: $(_DIR_)/试卷_P1.docx
