from pydesignflow import Block, task, Result
from .tools.tmds_generator import generate

class TMDSGenerator(Block):
    """TMDS generator"""
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    @task()
    def generate(self, cwd):
        r = Result()
        r.fragments = []

        outdir_fragments = cwd / 'fragments'
        outdir_fragments.mkdir()

        output = outdir_fragments / f'valid_tmds.sv'
        generate(output)

        r.fragments += [output]

        return r
