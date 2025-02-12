defmodule Changelog.PostTest do
  use Changelog.SchemaCase

  alias Changelog.Post

  describe "insert_changeset/2" do
    test "with valid attributes" do
      changeset = Post.insert_changeset(%Post{}, %{slug: "what-a-post", title: "What a Post", author_id: 42})
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Post.insert_changeset(%Post{}, %{title: "What a Post"})
      refute changeset.valid?
    end
  end

  describe "is_publishable/1" do
    test "is false when post is missing required fields" do
      refute Post.is_publishable(build(:post))
    end

    test "is false when post is published" do
      refute Post.is_publishable(build(:published_post))
    end

    test "is true when post has all fields and isn't published" do
      assert Post.is_publishable(insert(:publishable_post))
    end
  end

  describe "search" do
    setup do
      {:ok, phoenix: insert(:published_post, slug: "phoenix-post", title: "Phoenix", tldr: "A web framework for Elixir", body: "Chris McCord"),
            rails: insert(:published_post, slug: "rails-post", title: "Rails", tldr: "A web framework for Ruby", body: "DHH") }
    end

    test "finds post by matching title" do
      post_titles =
        Post
        |> Post.search("Phoenix")
        |> Repo.all
        |> Enum.map(&(&1.title))

      assert post_titles == ["Phoenix"]
    end

    test "finds post by matching tldr" do
      post_titles =
        Post
        |> Post.search("Ruby")
        |> Repo.all
        |> Enum.map(&(&1.title))

      assert post_titles == ["Rails"]
    end

    test "finds post by matching body" do
      post_titles =
        Post
        |> Post.search("DHH")
        |> Repo.all
        |> Enum.map(&(&1.title))

      assert post_titles == ["Rails"]
    end
  end
end
