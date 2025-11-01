_DIR_ := ./out

define GENCODE_PROMPT
import json
from docx import Document

# 读取JSON试题数据，TODO 根据用户输入调整
with open('./out/试题.json', 'r', encoding='utf-8') as f:
    questions = json.load(f)

# 内容采用追加形式，从 'in.docx' 输入，这部分不要动
doc = Document('in.docx')

# 添加标题，TODO 根据 JSON 生成合适的子标题
doc.add_heading('试题标题', level=2)

# 遍历试题并文档添加题目内容
for i, q in enumerate(questions, 1):
	## TODO 需要根据用户输入 JSON格式，输出题目内容到 out.docx

# 保存到输出文件
doc.save('out.docx')
endef
export GENCODE_PROMPT


all:
	$(file >$(_DIR_)/gen_.py, $(GENCODE_PROMPT))
	@if [ ! -f $(_DIR_)/gen.py ]; then \
		cp $(_DIR_)/gen_.py $(_DIR_)/gen.py; \
	fi
	@if [ ! -f "run_error" ]; then \
		echo "" > run_error; \
	fi
	ifl -y -i $(_DIR_)/$(TOPIC).json $(_DIR_)/gen.py run_error -t "修改 $(_DIR_)/gen.py 文件，根据给定 JSON 试题格式，修改并且补充为完整可正确执行的代码,注意执行错误信息。" 
	@rm -f out.docx
	python out/gen.py 2>>run_error	
	@if [ ! -f "out.docx" ]; then \
		cat run_error \
		echo "没有生成正确的 out.docx ，重试...."; \
		make -f gen.mk TOPIC=$(TOPIC); \
	fi
