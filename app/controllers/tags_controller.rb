class TagsController < ApplicationController
  before_action :set_tag, only: %i[ update destroy ]

  def index
    @tags = Current.user.tags.with_recipe_counts
  end

  # Renaming onto an existing tag merges the two.
  def update
    name = Tag.normalize_name(params.expect(tag: [ :name ])[:name])
    existing = Current.user.tags.where.not(id: @tag.id).find_by(name: name)

    if existing
      merge_into(existing)
      redirect_to tags_path, notice: "Merged into #{existing.name}.", status: :see_other
    elsif @tag.update(name: name)
      redirect_to tags_path, notice: "Renamed to #{@tag.name}.", status: :see_other
    else
      redirect_to tags_path, alert: "Tag #{@tag.errors.full_messages.to_sentence.downcase_first}.", status: :see_other
    end
  end

  def destroy
    @tag.destroy!
    redirect_to tags_path, notice: "Deleted the #{@tag.name} tag. Its recipes are still there.", status: :see_other
  end

  private
    def set_tag
      @tag = Current.user.tags.find(params[:id])
    end

    def merge_into(target)
      Tag.transaction do
        already_tagged = target.taggings.pluck(:recipe_id)
        @tag.taggings.where(recipe_id: already_tagged).delete_all
        @tag.taggings.update_all(tag_id: target.id)
        @tag.destroy!
      end
    end
end
