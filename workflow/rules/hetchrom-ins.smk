
rule repeatmasker_hetchrom:
    input:
        repeats = config.get('TRANSPOSON_FASTA',None),
        fasta = config.get('HETCHROM_FASTA'),
    output:
        'results/hetchrom-ins/repeatmasker/' + config.get('HETCHROM_FASTA').split('/')[-1] + '.cat.gz',
        'results/hetchrom-ins/repeatmasker/' + config.get('HETCHROM_FASTA').split('/')[-1] + '.masked',
        'results/hetchrom-ins/repeatmasker/' + config.get('HETCHROM_FASTA').split('/')[-1] + '.out',
        'results/hetchrom-ins/repeatmasker/' + config.get('HETCHROM_FASTA').split('/')[-1] + '.tbl',
    threads:
        24
    params:
        dir = "results/hetchrom-ins/repeatmasker/"
    conda:
        "../envs/repeatmasker.yaml"
    resources:
        mem=128000,
        cpus=24,
        time=240,
    shell:
        """
        RepeatMasker -e ncbi -pa {threads} -s \
            -lib {input.repeats} -gff \
            -no_is -nolow -dir {params.dir} \
            {input.fasta}
        """

rule parse_repeatmasker_y:
    input:
        rpmskr = rules.repeatmasker_hetchrom.output[2],
        lookup = "resources/te_id_lookup.curated.tsv.txt"
    output:
        bed_all = "results/hetchrom-ins/insertions.csv"
    conda:
        "../envs/bioc-general.yaml"
    script:
        "../scripts/parse_rpm.R"
