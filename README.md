# C-template

This is a template intended for multi-purpose C projects, that can easily be modified for C++.

## Installation

Clone the repo :
```bash
git clone https://github.com/Bitwise-re/c-template.git
``` 
Or using ssh : 
```bash
git clone git@github.com:Bitwise-re/c-template.git
```

Then delete history :
```bash
rm -r .git
git init
```

> [!TIP]
> You can also click on `use this template` on the repo page to create a new repo based on this template.


## Project Structure

```
/
├── .github/
|   └── workflows
|       ├── build.yml
|       ├── deploy.yml
|       └── test.yml
├── bin/
├── build/
|   ├── assets/
|   ├── linux/
|   └── windows/
├── scripts/
|   ├── createnode.sh
|   └── getnodes.sh
├── src/
│   └── app/
|       ├── main.c
|       └── flags.gcc
├── temp/
├── templates/
|   ├── lib.c
|   ├── lib.h
|   ├── main.c
|   └── onode.mk
├── test/
├── LICENSE
├── Makefile
├── README.md
└── vars.mk
```

## Usage

### The Nodes

The source folder is structured by nodes, there are 3 types of node :
- __Other node__ \
Other nodes are custom nodes holding their own Makefile which should include 3 specific variables : \
`__FILES` -> holds the files built by this node.\
`__DEPS` -> holds the files on which depend the files above.\
`__IMPL_LINK` -> How to implement the node's files in the linking step of another file which depend on those files. \
A node containing a Makefile is processed as an *Other node*.

- __Executable node__ \
Executable nodes hold the source code for an executable.
A node containing a main.c file is processed as an *Executable node*.
- __Library node__ \
Library nodes are holding source code for shared libraries (`.dll` on windows and `.so` on linux).
Any node which isn't an *Executable node* nor an *Other node* is processed as a *Library node*. 

### The Makefiles

There are 2 main Makefiles in this template : [./Makefile](https://github.com/Bitwise-re/c-template/blob/main/Makefile) wich holds the recipes and [./vars.mk](https://github.com/Bitwise-re/c-template/blob/main/vars.mk) which holds all structure related variables as well as functions for the recipes.

Project structure, extensions used and flags for each step of the build chain can be found in [./vars.mk](https://github.com/Bitwise-re/c-template/blob/main/vars.mk).

> [!TIP]
> While the flags for each step of the build chain are the same for every node, you can add flags for the linking step by adding them in `{step_id}.flags`, where *step_id* can be found in [./vars.mk](https://github.com/Bitwise-re/c-template/blob/main/vars.mk).. Each flags with the prefix W_ will be used for windows builds and L_ for linux builds.

### Adding files to be built

To add an executable, just create a new subfolder in `./src/`containing a `main.c` file. 
Same for adding a file with custom build process : just create a new subfolder in `./src/` containing a `Makefile`.
To add a library, create a new subfolder in `./src/` with source code in it.
To add ressources/assets to be directly inserted in the final product's root folder, put them in `./build/assets`.

> [!TIP]
> To add new nodes, the main Makefile provides recipes :
> | Node Type | Command |
> | --- | --- |
> | Executable | make \__ne\_{node_name} |
> | Library | make \__nl\_{node_name} |
> | Other | make \__no\_{node_name} |

## The build process

```mermaid
flowchart TD;
    START((make build)) --> RC@{ shape: procs, label: "Clean/Reset"}
    RC --> MKA@{ shape: procs, label: "make all" }
    MKA --> CLN@{ shape: procs, label: "Clean" }
    CLN --> CPB@{ shape: proc, label: "Copy binaries to build folder" }
    CPB --> CLI@{ shape: proc, label: "Remove import libraries from build folder" }
    CLI --> CPA@{ shape: proc, label: "Copy assets to build folder" }
    CPA --> CLB@{ shape: proc, label: "Empty bin folder" }
    CLB --> END@{ shape: double-circle, label: "Done" }
    subgraph RCG [ Clean/Reset ]
        RCG_START((make cr)) --> RCG_BIN@{ shape: proc, label: "Empty bin directory" }
        RCG_BIN --> RCG_BLD@{ shape: proc, label: "Empty build directory" }
        RCG_BLD --> RCG_CLN@{ shape: f-circ, label: "Clean" }
        RCG_CLN --> RCG_FEN@{ shape: hex, label: "For each Executable and Library node" }
        RCG_FEN -->|Next| RCG_DLD@{ shape: proc, label: "Delete dependency files" }
        RCG_DLD --> RCG_DLI@{ shape: proc, label: "Delete pre-processor files" }
        RCG_DLI --> RCG_DLA@{ shape: proc, label: "Delete assembly files" }
        RCG_DLA --> RCG_DLO@{ shape: proc, label: "Delete object files" }
        RCG_DLO --> RCG_FEN
        RCG_FEN ---->|Done| RCG_FEON@{ shape: hex, label: "For each Other node" }
        RCG_FEON -->|Next| RCG_CON@{ shape: procs, label: "Execute 'make clean' in the node" }
        RCG_CON --> RCG_FEON
        RCG_FEON -->|Done| RCG_END@{ shape: double-circle, label: "Done" }
    end
    subgraph MKA_G [ make all ]
        MKA_START((make all)) --> MKA_FEN@{ shape: hex, label: "For each Node" }
        MKA_FEN -->|Next| MKA_INO@{ shape: diamond, label: "Is it an Other node ?" }
        MKA_INO -->|Yes| MKA_BON@{ shape: procs, label: "Build Other node" }
        MKA_INO -->|No| MKA_BDN@{ shape: procs, label: "Build Executable/Library node" }
        MKA_FEN -->|Done| MKA_END@{ shape: double-circle, label: "Done" }
    end
    subgraph MKO [ Build an Other node ]
        MKO_START(("make %")) --> MKO_GTN@{ shape: proc, label: "Get associated node" }
        MKO_GTN --> MKO_GTD@{ shape: proc, label: "Get dependencies from the node's Makefile" }
        MKO_GTD --> MKO_BDD@{ shape: procs, label: "Build dependencies" }
        MKO_BDD --> MKO_BLD@{ shape: procs, label: "Execute 'make %' in the node" }
        MKO_BLD --> MKO_END@{ shape: double-circle, label: "Done" }
    end
    subgraph MKN [ Build a Library/Executable node ]
        MKN_START(("make %(.exe) / %.so(.dll)")) --> MKN_GTN@{ shape: proc, label: "Get associated node" }
        MKN_GTN --> MKN_FEF@{ shape: hex, label: "For each source file (.c)" }
        MKN_FEF -->|Next| MKN_CDF@{ shape: proc, label: "Create dependency file" }
        MKN_CDF --> MKN_CIF@{ shape: proc, label: "Create pre-processor file" }
        MKN_CIF --> MKN_CAF@{ shape: proc, label: "Create assembly file" }
        MKN_CAF --> MKN_COB@{ shape: proc, label: "Create object file" }
        MKN_COB --> MKN_FEF
        MKN_FEF -->|Done| MKN_DEP@{ shape: proc, label: "Get dependencies from the node's dep files" }
        MKN_DEP --> MKN_BDD@{ shape: procs, label: "Build dependencies" }
        MKN_BDD --> MKN_LNK@{ shape: proc, label: "Link object files and dependencies into %" }
        MKN_LNK --> MKN_END@{ shape: double-circle, label: "Done" }
    end
    RC -..-> RCG_START
    CLN -..-> RCG_CLN
    MKA -..-> MKA_START
    MKA_BON -..-> MKO_START
    MKA_BDN -..-> MKN_START
    MKO_BDD -..-> MKA_START
    MKN_BDD -..-> MKA_START
    MKN_END -..-> FEN
    MKO_END -..-> FEN
```

## Included Github Workflows

This templates comes with Github Workflows.
- Test :
  Triggered on PR, used to verify modifications to important branches does not bring bugs.
  Passes the code through a series of tests, including the whole buildling process, in different environnements.
- Build :
  Triggered on demand by other workflows, covers the whole building process for the linux and windows app.
- Deploy :
  Triggered by a push on the main branch, calls the build process and package the output into a release.

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

> [!CAUTION]
> Please make sure to update tests as appropriate.

## License

This project is under [GNU 3 License](https://github.com/Bitwise-re/c-template/blob/main/LICENSE)


