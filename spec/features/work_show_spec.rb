require 'spec_helper'

describe "display a work as its owner" do
  let(:work_path) { "/concern/generic_works/#{work.id}" }

  context "as the work owner" do
    let(:work) { create(:work_with_one_file, title: ["Magnificent splendor"], user: user) }
    let(:user) { create(:user) }
    before do
      sign_in user
      visit work_path
    end

    it "shows a work" do
      expect(page).to have_selector 'h1', text: 'Magnificent splendor'

      # Has a form for uploading more files
      expect(page).to have_selector "form#fileupload[action='/concern/container/#{work.id}/file_sets']"

      # and the form redirects back to this page after uploading
      expect(page).to have_selector '#redirect-loc', text: work_path

      # Displays FileSets already attached to this work
      within '.related_files' do
        expect(page).to have_selector '.filename', text: 'filename.pdf'
      end
    end
  end

  context "as a user who is not logged in" do
    let(:work) { create(:public_generic_work, title: ["Magnificent splendor"]) }
    before do
      visit work_path
    end

    it "shows a work" do
      expect(page).to have_selector 'h1', text: 'Magnificent splendor'

      # Doesn't have the upload form for uploading more files
      expect(page).not_to have_selector "form#fileupload"
    end
  end
end
