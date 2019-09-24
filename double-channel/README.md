# Double-channel FRET analysis using machine learning

* [Machine learning test results](/experiments/README.md)

# Method

We used a long-short-term memory neural network to classifiy the double-channel single molecule trace signals. The raw data of each trace is a serial of frames where each frame is composed of a donor intensity and a acceptor intensity. We pre-precess the raw data by normalizing the traces and grouping each consequtive $n_{bin}$ traces as one input feature. We found the concordance plateaued when $n_{bin} \ge 10$, and set $n_{bin} = 10$ for our analysis. We connected our long-short-term memory bi-directionally to increase the concordance of the classification because the state of a earlier frame may depend on features from later frames. For example, ** fill in examples**. 
