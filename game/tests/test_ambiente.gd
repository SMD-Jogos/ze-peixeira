extends GutTest

func test_ambiente_esta_pronto():
	assert_eq(1 + 1, 2, "sanity check do GUT rodando via CLI headless")
