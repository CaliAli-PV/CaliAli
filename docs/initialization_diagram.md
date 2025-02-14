
# hola
``` mermaid
graph TD;
    D[Filtered Maximum projection];
    D --> E[Binarization];
    E --> F[Remove Small Objects using Area Filter];
    F --> G[Label Connected Components];
    G --> H[Select Largest Dendritic Structure];
    H --> I[Active Contour Refinement using Chan-Vese];
    I --> J[Main Branch Isolation];
    J --> K[Remove dendrite from binary image ];
    K --> L[Decrease Binarization threshold];
    L -->|Valid Dendrite Segments| M[Relabel and Assign IDs];
    K-->|Repeat until empty| H;
    L-->|Repeat| E;
```

hola