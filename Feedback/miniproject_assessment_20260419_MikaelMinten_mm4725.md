# MiniProject Assessment for Mikael Minten

## Computing

### A1 — Project Organisation

The project is neatly organised, with `code/`, `data/`, and `results/` all present at the top level, and the `results/` directory left empty in the repository so outputs are generated rather than stored. The `README.md` is more than a placeholder: it documents R and LaTeX requirements, lists package dependencies, explains what packages are used for, and gives a clear account of the file structure and workflow. A `.gitignore` is also present, which helps protect the repository from accidental clutter. The only mild organisational concern is that the README advertises generated outputs such as `results/report.pdf` and `results/data_clean.csv`, while the repository itself correctly omits them; future submissions would benefit from making that generated-versus-committed distinction even more explicit so the workflow expectations are unambiguous.

### A2 — Single-Script Reproducibility

#### Workflow & Solution Quality

The automated run did not start because no `run_MiniProject.py` or `run_MiniProject.sh` was found in the project root. There is a real orchestration script in `code/run_analysis.sh`, and its contents cover the expected stages in sequence: `Rscript data_preparation.R`, `Rscript model_fitting.R`, then `pdflatex`/`bibtex` compilation of `latex.tex`, with the final PDF moved to `../results/report.pdf`. That gives good evidence that the student built an end-to-end pipeline, but it does not satisfy the submission requirement that the project run from a single entry script named `run_MiniProject.*` from the `MiniProject` root, so reproducibility cannot be validated in the grading environment. A next step would be to place a root-level `run_MiniProject.sh` wrapper in `MiniProject/`, call `code/run_analysis.sh` from there, and add a small preflight check for required tools such as `Rscript`, `pdflatex`, and `bibtex` so failures are easier to diagnose.

### A3 — Code Quality & Style

#### Script-level Technical Feedback

The codebase is substantial and well modularised, with 834 lines across shell and R, 21 function definitions, and a high comment density of 0.179. `code/data_preparation.R` is particularly clear: functions such as `load_data`, `clean_growth_data`, and `save_cleaned_data` separate validation, transformation, and export cleanly, while `code/model_fitting.R` breaks the analysis into reusable units such as `get_start_params`, `run_growth_models_multistart`, and `compute_akaike_weights`. The largest script, `code/model_fitting.R` at 592 lines, still remains readable because the model definitions (`baranyi_model`, `buchanan_model`, `linear_model`) and downstream analysis helpers are named meaningfully and grouped by task, although there are a few rough edges such as repeated `require(...)` calls, some spelling inconsistencies (`baryanni_fits`, `collumn`), and a long `main()` block that carries a lot of workflow state at once. A concrete improvement would be to split the long `main()` section in `code/model_fitting.R` into helper functions for fitting, model comparison, thermal analysis, and plotting, and to standardise object names such as `baranyi_fits` throughout.

### A4 — Model Fitting & Statistical Analysis

#### NLLS

The fitting strategy goes well beyond the minimum requirement: `code/model_fitting.R` implements nonlinear least squares for the Baranyi and Buchanan models using `nls_multstart` with `minpack.lm`, alongside a linear comparator fitted with `lm`. Starting values are handled carefully in `get_start_params`, where `N_0`, `N_max`, `r_max`, and `t_lag` are estimated from each curve using extrema and rolling regressions, and convergence failures are guarded with `tryCatch`, which is exactly the kind of protection nonlinear workflows need. The report and code together show coherent model comparison through AIC, AICc, BIC, and Akaike weights, and the Results section reports convergence counts for 267 curves, which gives confidence that the fitting was not merely nominal. The main weakness is computational scope and reporting clarity: the Methods section states 3,000 random starts while the code uses `n_iter = 4000`, and the evidence bundle undercounts the named models, so future work could make the start-value heuristics, parameter bounds, and final comparison outputs more explicitly exported and documented in CSV form.

### A5 — Version Control & Workflow Discipline

The Git history shows sustained development rather than a last-minute dump, with 24 MiniProject commits and a wider repository history of 160 commits. Several messages are genuinely informative — for example, improving `get_start_params`, adding linear-model support, wrapping the workflow in `main()`, and fixing LaTeX compilation issues — which makes the development process easy to follow. Some late commits are more generic, such as “final changes” or “Uploading final changes to the project,” so the main improvement would be to keep commit messages consistently specific right through the final polishing stage.

## Report

### B1 — Report Format & Presentation

The report meets most of the formal presentation requirements well: `article` class at 11pt is used, `\onehalfspacing` and `lineno` are present, the title page includes author and word count, the abstract is close to the expected 200 words, and the bibliography uses a non-numeric `apalike` style. The display-item count is also in the target range, with 2 figures and 2 tables, all with captions. The main formal issue is length, since the body word count is approximately 3785, which exceeds the 3500-word limit and warrants a small deduction. The missing compiled PDF in the repository is not a report-content problem here because the LaTeX source and structure are present, but future submissions would benefit from tighter editing in the Discussion to bring the manuscript within the limit.

### B2 — Introduction & Objectives

The Introduction is intellectually ambitious and well read, with a strong literature-based account of microbial growth phases, primary versus secondary models, and the mechanistic-versus-phenomenological distinction. The two research questions are clearly stated and emerge naturally from the preceding narrative, especially the link between primary-model choice and downstream temperature analysis. The main drag on this section is alignment with the course framing: the automated checks only found limited explicit grounding in the required temperature-dependent single-population metabolism/growth framing and limited direct anchoring to both relevant MQB chapter themes, and the distinction between biological and methodological objectives is more implicit than explicit. A stronger version of this introduction would have tied the microbial growth problem more directly to the course’s metabolism-and-populations framing in a few concise sentences before moving into the modelling literature.

### B3 — Methods (including Computing Tools)

The Methods section is detailed and technically competent. It states the model equations clearly, explains data cleaning and grouping decisions, gives a reproducible account of NLLS fitting with multistart optimisation, and justifies the use of AICc and Akaike weights for model selection. The `Computational Tools` subsection is present and useful, naming R 4.3.3 and the main packages used for wrangling, fitting, diagnostics, mixed modelling, and plotting, although the package list is more descriptive than justificatory in places and could do more to explain why each tool was preferable for this analysis rather than merely what it did. A concrete improvement would be to tighten the package discussion and align the written fitting settings exactly with the implemented code, especially the number of multistart iterations and convergence controls.

### B4 — Results & Display Items

The Results section is well populated and follows the project objectives in a sensible order: summary statistics first, then model selection, then temperature dependence. Four display items are included, which sits comfortably within the expected range, and the captions are informative enough to let the reader understand what each table or figure is showing. The model comparison is reported clearly through Akaike-weight summaries and convergence counts, and the thermal analysis is supported by both a table of mixed-model coefficients and a figure. There is some interpretive language mixed into the Results — for example, statements about what the findings “indicate” or “suggest” begin to edge into Discussion territory — so future reports would benefit from keeping this section slightly more factual and moving the broader interpretation downstream.

### B5 — Discussion, Conclusions & Abstract

This is the strongest part of the write-up. The Discussion returns to the original questions, interprets the model-selection results biologically, and gives a nuanced account of when the linear, Buchanan, and Baranyi models are likely to perform differently depending on phase coverage, medium, and data sparsity. Advanced methods are engaged with substantively rather than name-checked: the text explains what maximum likelihood would add through alternative error models, what Bayesian hierarchical modelling could contribute through priors and partial pooling across strains, and what machine-learning approaches might gain in predictive flexibility while losing in interpretability and extrapolation. The abstract is self-contained and specific, and the conclusion is clear, though the section could be slightly tighter because the advanced-methods discussion is long enough to contribute to the word-count problem. 

## Summary

Final classification (student-facing):

- Part A (Computing): Distinction
- Part B (Report): Distinction
- Overall: Distinction
