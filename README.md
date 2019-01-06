# HSLC ContentDM-to-MODS Mappings and Intermediate Processes
This repository contains:
- `/mods-mappings`: MODS maps used to process ContentDM XML exports using the Islandora XML Based ContentDM Migration modules
- `/mods-processes`: XSL transformations used to perform intermediate processes to affect interventions on the MODS XML produced by the module, prior to batch ingest.
- `crosswalks`: XSL transformations providing crosswalks from MODS to other target formats such as Qualified Dublin Core

## MODS Processes
| File | Description |
| -------- | ------- |
| hslc-mods-updates-template.xsl | Affects standard processing to handle such things as tokenizing values, removing empty elements, etc. | 
| cdm-mods-final-level-to-books.xsl | Overrides standard handling of ContentDM hiearchical compounds (to collections hierarchy) by making them books. |
| cdm-mods-final-level-to-books-select.xsl | Allows selectively changing collections into books. This can be cloned for collections requiring different criteria. |
| cdm-mods-updates-single-children.xsl | Removes the parent object from single page compounds. It's recommended this is not used when creating books. |

Various sample Perl scripts may also be present showing the chaining of transformations to produce desired results. These are set up to use Saxonica. You may sub in an alternative xsl processor, or create scripts in the language of your choice. These can be employed as is, adapted, or referenced to author your own.

No warranty is implied. Users are solely responsible for testing and verify all results.

