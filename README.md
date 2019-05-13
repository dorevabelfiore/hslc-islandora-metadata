# HSLC ContentDM-to-MODS Mappings and Intermediate Processes
This repository contains:
- `/mods-mappings`: MODS maps used to process ContentDM XML exports using the Islandora XML Based ContentDM Migration modules
- `/mods-processes`: XSL transformations used to perform intermediate processes to affect interventions on the MODS XML produced by the module, prior to batch ingest.
- `crosswalks`: XSL transformations providing crosswalks from MODS to other target formats such as Qualified Dublin Core

# MODS Processes
| xsl / perl | Functions |
| ---------- | ---------- |
| `cdm-mods-final-level-to-compounds.xsl` | Alters standard crosswalk handling of hierarchical compounds (into a hierarchy of collections and children) by changing any (sub)collection containing only image objects (no subcollections) into a compound object. This can be modified to be less selective, i.e. create compounds with arbitrary non-collection cModel types. This should usually be use with `cdm-mods-updates-single-children.xsl` following. Requires passing in $islandora-namespace parameter. |
| `cdm-mods-updates-single-children.xsl` | When a compound object has only one child, this removes the parent object, moves the parent metadata to the child, and assigns the child to the collection the parent was a member of. |
| `cdm-mods-final-level-to-books.xsl` | Alters standard crosswalk handling of hierarchical compounds by changing any (sub)collection containing only image objects (no subcollections) into a book, and its children into pages. Requires passing in $islandora-namespace parameter. |
| `cdm-mods-final-level-to-newspapers.xsl` | Alters standard crosswalk handling of hierarchical compounds by changing any (sub)collection containing only image objects (no subcollections) into a newspaper issue, and its children into newspaper pages. Requires passing in $islandora-namespace parameter. |
| `split-mods-files.xsl` | For handling very large files it is sometimes required to split output files into smaller batches. Set the `$object-per-file` param to the number of objects per file. Note this stylesheet does use a saxon extension functions, and therefore has a dependency on it. |

# Sequencing of Processes
Transformations that don't alter content model choice can generally be run at any point in a processing chain unless the content model is being used as a condition. Transformations that _do_ alter content model must be run in a specific sequence or results will not be as desired. Guidance on the order of these transforms is as follows:

- `cdm-mods-final-level-to-books.xsl`, or any transformation changing the content model of the final level in a hierarchical structure into books - as might be done selectively - should always be run first. 
- If books are being created selectively, and all other final levels of the collections/object hierarchy into compounds using `cdm-mods-final-level-to-compounds.xsl`, that is run _following_ the transform to create books.
- The update to remove parent objects from single children compounds, `cdm-mods-updates-single-children.xsl` is run last.

Various sample Perl scripts may also be present showing the chaining of transformations to produce desired results. These are set up to use Saxonica. You may sub in an alternative xsl processor, or create scripts in the language of your choice. These can be employed as is, adapted, or referenced to author your own.

No warranty is implied. Users are solely responsible for testing and verify all results.

