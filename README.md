This repository is archived, if you need a fast way to screen for (colibactin) genes, use [kbo](https://github.com/tmaklin/kbo).

# clbtype

Command-line tool for screening _E. coli_ assemblies for the presence
and absence of genes belonging to the colibactin gene cluster ('pks
island') and genes coding colibactin resistance proteins (clbS).

## Installation
clbtype is available from the [releases page](https://github.com/tmaklin/clbtype/releases).

### From source
#### Requirements
- CMake v3.11
- C++ compiler with C++14 support
#### Compiling
```
git clone https://github.com/tmaklin/clbtype
cd clbtype
cmake .
make -j
```

## Usage
### Query assembly
From the clbtype directory, run
```
./query_db.sh /path/to/query.fna.gz
```
This will print information about the pks island genes that are found in the query sequence.

## Details
The pks island genes in the reference database were extracted from the
genome sequence of _Escherichia coli_
[IHE3034](https://www.ebi.ac.uk/ena/browser/view/GCA_000025745.1)
described in
[10.1073/pnas.0915077107](https://www.pnas.org/doi/full/10.1073/pnas.0915077107).

## References
clbtype incorporates code from [bifrost](https://github.com/pmelsted/bifrost)
and [BlastFrost](https://github.com/nluhmann/BlastFrost). If you use
clbtype, please cite bifrost and BlastFrost as
```
@article{holley2020bifrost,
  title={Bifrost: highly parallel construction and indexing of colored and compacted de Bruijn graphs},
  author={Holley, Guillaume and Melsted, P{\'a}ll},
  journal={Genome biology},
  volume={21},
  number={1},
  pages={1--20},
  year={2020},
  publisher={BioMed Central}
}

@article{luhmann2021blastfrost,
  title={BlastFrost: Fast querying of 100,000 s of bacterial genomes in Bifrost graphs},
  author={Luhmann, Nina and Holley, Guillaume and Achtman, Mark},
  journal={Genome biology},
  volume={22},
  number={1},
  pages={1--15},
  year={2021},
  publisher={BioMed Central}
}
```

## License
The source code from this project is subject to the terms of the GNU
General Public License as published by the Free Software Foundation,
either version 3 of the License, or (at your option) any later
version. You should have received a copy of the GNU General Public
License along with this program. If not, see
<https://www.gnu.org/licenses/>.

- bifrost is licensed under the [BSD 2-clause license](https://github.com/pmelsted/bifrost/blob/v1.0.6.4/LICENSE])
- BlastFrost is licensed under the [GPLv3 license](https://github.com/nluhmann/BlastFrost/blob/master/LICENSE)
