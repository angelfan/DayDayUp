# 对博客进行分类

1. 提取博客中的单词列表:
```python
(博客名1: {单词1: 1， 单词2: 2})
(博客名2: {单词1: 1， 单词2: 2})
(博客名3: {单词1: 1， 单词2: 2})
```

2. 减躁: 简单的方法是只选择介于某个百分比的单词
```python
for w,bc in apcount.items():
  frac=float(bc)/len(feedlist)
  i f frac>O.l and frac<O.5: wordlist.append(w)
```

3. 分级聚类
可以用皮尔逊计算紧密度
博客名1 分别各博客名2, 博客名3比较 紧密度最佳则聚类