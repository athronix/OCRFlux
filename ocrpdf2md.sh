# 1. 创建脚本文件
cat > ~/OCRFlux/pdf_to_markdown.sh << 'EOF'
#!/bin/bash

# 检查参数
if [ "$#" -ne 1 ]; then
    echo "使用方法: $0 <PDF文件路径>"
    echo "示例: $0 /home/Ubuntu/Downloads/test.pdf"
    exit 1
fi

PDF_FILE="$1"

# 检查文件是否存在
if [ ! -f "$PDF_FILE" ]; then
    echo "错误: 文件 '$PDF_FILE' 不存在"
    exit 1
fi

echo "开始处理PDF文件: $PDF_FILE"
echo "======================================="

# 确保在OCRFlux目录中
cd ~/OCRFlux

# 第一步：处理PDF生成JSONL
echo "第一步: 正在处理PDF..."
python -m ocrflux.pipeline ./localworkspace --data "$PDF_FILE" --model ~/models/OCRFlux-3B

# 检查第一步是否成功
if [ $? -eq 0 ]; then
    echo "第一步完成: PDF处理成功"
    echo "======================================="
    
    # 第二步：生成Markdown文件
    echo "第二步: 正在生成Markdown文件..."
    python -m ocrflux.jsonl_to_markdown ./localworkspace
    
    if [ $? -eq 0 ]; then
        echo "======================================="
        echo "✅ 处理完成!"
        echo "📁 Markdown文件位置: ~/OCRFlux/localworkspace/markdowns/"
        echo "📄 查看结果:"
        echo "   ls -la ~/OCRFlux/localworkspace/markdowns/"
        echo "   find ~/OCRFlux/localworkspace/markdowns/ -name '*.md'"
    else
        echo "❌ 第二步失败: 生成Markdown文件时出错"
        exit 1
    fi
else
    echo "❌ 第一步失败: PDF处理时出错"
    exit 1
fi
EOF

# 2. 设置执行权限
chmod +x ~/OCRFlux/pdf_to_markdown.sh

# 3. 使用脚本
~/OCRFlux/pdf_to_markdown.sh /home/Ubuntu/Downloads/test.pdf
