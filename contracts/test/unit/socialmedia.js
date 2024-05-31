// Import Hardhat plugins and ethers
const { expect } = require("chai");

// Describe the contract and its tests
describe("SocialMedia", function () {
  let SocialMedia;
  let socialMedia;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    // Deploy the contract before each test
    SocialMedia = await ethers.getContractFactory("SocialMedia");
    [owner, addr1, addr2] = await ethers.getSigners();
    socialMedia = await SocialMedia.deploy();
  });

  // Test case 1: Registering a user
  it("Should register a new user", async function () {
    const name = "Alice";
    const bio = "Hello, I'm Alice a SE Engineer";

    await socialMedia.registerUser(name, bio, "ImageHash1");
    const user = await socialMedia.users(owner.address);
    expect(user.name).to.equal("Alice");
  });

  // Test case 2: Creating a post
  it("Should create a new post", async function () {
    await socialMedia.createPost("Content1", "ImageHash1");
    const post = await socialMedia.posts(1); // Assuming postId starts from 1
    expect(post.content).to.equal("Content1");
  });

  // Test case 3: Editing a post
  it("Should edit an existing post", async function () {
    await socialMedia.createPost("Content1", "ImageHash1");
    await socialMedia.editPost(1, "Edited content", "NewImageHash");
    const post = await socialMedia.posts(1);
    expect(post.content).to.equal("Edited content");
  });

  // Test case 4: Deleting a post
  it("Should delete an existing post", async function () {
    await socialMedia.createPost("Content1", "ImageHash1");
    await socialMedia.deletePost(1);
    const post = await socialMedia.posts(1);
    expect(post.content).to.equal(""); // Assuming content is emptied after deletion
  });

  // Test case 5: Upvoting a post
  it("Should upvote a post", async function () {
    await socialMedia.createPost("Content1", "ImageHash1");
    await socialMedia.upvote(1);
    const post = await socialMedia.posts(1);
    expect(post.upvote).to.equal(1);
  });

  // Add more test cases for other functions

});
