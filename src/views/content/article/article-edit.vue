<!-- 文章编辑弹窗 -->
<template>
  <el-drawer
    class="edit-table"
    :title="isUpdate ? '修改新闻' : '添加新闻'"
    :visible.sync="showDrawer"
    :direction="direction"
    :size="'75%'"
    :before-close="close"
  >
    <el-form
      ref="form"
      :model="form"
      :rules="rules"
      label-width="90px"
      style="padding: 50px 100px"
    >
      <el-form-item label="新闻封面：">
        <uploadImage :limit="1" v-model="form.imageUrl"></uploadImage>
      </el-form-item>
      <el-row :gutter="15">
        <el-col :sm="16">
          <el-form-item label="新闻标题:" prop="title">
            <el-input
              clearable
              :maxlength="200"
              v-model="form.title"
              placeholder="请输入新闻标题"
            />
          </el-form-item>
        </el-col>
        <el-col :sm="12">
          <el-form-item label="作者:" prop="author">
            <el-input
              clearable
              :maxlength="50"
              v-model="form.author"
              placeholder="请输入作者"
            />
          </el-form-item>
          <el-form-item label="新闻状态:" prop="status">
            <el-radio-group v-model="form.status">
              <el-radio :label="1">生效中</el-radio>
              <el-radio :label="2">已停止</el-radio>
            </el-radio-group>
          </el-form-item>
        </el-col>
        <el-col :sm="16">
          <el-form-item label="关联基金:" prop="fundId">
            <el-select
              v-model="form.fundId"
              style="width: 100%"
              placeholder="请选择基金"
            >
              <el-option
                v-for="item in fundList"
                :key="'fund' + item.id"
                :label="item.name"
                :value="item.id"
              >
              </el-option>
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>
      <!-- 富文本编辑器 -->
      <el-form-item label="新闻内容:" prop="content">
        <tinymce-editor v-model="form.content" :init="initEditor" />
      </el-form-item>
      <el-form-item
        style="text-align: center; margin-left: -100px; margin-top: 10px"
      >
        <el-button @click="save" type="primary" size="medium">保存 </el-button>
        <el-button @click="$emit('close')" size="medium">返回</el-button>
      </el-form-item>
    </el-form>
  </el-drawer>
</template>

<script>
import uploadImage from "@/components/uploadImage";
import "@riophae/vue-treeselect/dist/vue-treeselect.css";
import TinymceEditor from "@/components/TinymceEditor";
import { mapGetters } from "vuex";
export default {
  name: "ArticleEdit",
  props: {
    // 弹窗是否打开
    visible: Boolean,
    // 修改回显的数据
    data: Object,
    // 栏目数据
    cateList: Array,
  },
  components: { uploadImage, TinymceEditor },
  data() {
    return {
      showDrawer: this.visible,
      direction: "rtl",
      // 表单数据
      form: Object.assign({}, this.data),
      // 表单验证规则
      rules: {
        title: [{ required: true, message: "请输入新闻标题", trigger: "blur" }],
        status: [
          { required: true, message: "请选择新闻状态", trigger: "blur" },
        ],
        sort: [{ required: true, message: "请输入排序号", trigger: "blur" }],
        fundId: [
          { required: false, message: "请选择关联基金", trigger: "blur" },
        ],
      },
      // 提交状态
      loading: false,
      // 是否是修改
      isUpdate: false,
      // 上传目录
      updDir: "article",
    };
  },
  watch: {
    data() {
      if (this.data) {
        this.form = Object.assign({}, this.data);
        this.isUpdate = true;
      } else {
        this.form = {};
        this.isUpdate = false;
      }
    },
  },
  computed: {
    ...mapGetters(["fundList"]),
    // 初始化富文本
    initEditor() {
      return {
        height: 450,
        branding: false,
        skin_url: "/tinymce/skins/ui/oxide",
        content_css: "/tinymce/skins/content/default/content.css",
        language_url: "/tinymce/langs/zh_CN.js",
        language: "zh_CN",
        plugins:
          "code print preview fullscreen paste searchreplace save autosave link autolink image imagetools media table codesample lists advlist hr charmap emoticons anchor directionality pagebreak quickbars nonbreaking visualblocks visualchars wordcount",
        toolbar:
          "fullscreen preview code | undo redo | forecolor backcolor | bold italic underline strikethrough | alignleft aligncenter alignright alignjustify | outdent indent | numlist bullist | formatselect fontselect fontsizeselect | link image media emoticons charmap anchor pagebreak codesample | ltr rtl",
        toolbar_drawer: "sliding",
        images_upload_handler: (blobInfo, success, error) => {
          let file = blobInfo.blob();
          // 使用axios上传
          const formData = new FormData();
          formData.append("file", file, file.name);
          this.$http
            .post("/oss/upload", formData)
            .then((res) => {
              if (res.data.code === 200) {
                success(res.data.data);
              } else {
                error(res.data.msg);
              }
            })
            .catch((e) => {
              console.error(e);
              error(e.message);
            });
        },
        file_picker_types: "media",
        file_picker_callback: () => {},
      };
    },
  },
  mounted() {
    this.getInfo();
    if (this.fundList.length === 1) {
      this.form.fundId = this.fundList[0].id;
      console.log("-------", this.form);
    }
  },
  methods: {
    /* 获取文章详情 */
    getInfo() {
      if (this.data.id > 0) {
        this.$http
          .get("/cfNews/info/" + this.data.id)
          .then((res) => {
            if (res.data.code === 200) {
              this.form = res.data.data;
              this.isUpdate = true;
            } else {
              this.$message.error(res.data.message);
            }
          })
          .catch((e) => {
            this.$message.error(e.message);
          });
      }
    },
    /* 保存编辑 */
    save() {
      this.$refs["form"].validate((valid) => {
        if (valid) {
          this.loading = true;
          this.$http
            .post(this.isUpdate ? "/cfNews/edit" : "/cfNews/add", this.form)
            .then((res) => {
              this.loading = false;
              if (res.data.code === 200) {
                this.$message.success(res.data.message);
                if (!this.isUpdate) {
                  this.form = {};
                }
                this.updateVisible(false);
                this.$emit("done");
              } else {
                this.$message.error(res.data.message);
              }
            })
            .catch((e) => {
              this.loading = false;
              this.$message.error(e.message);
            });
        } else {
          return false;
        }
      });
    },
    /* 更新visible */
    updateVisible(value) {
      this.$emit("update:visible", value);
    },
    /* 关闭页面 */
    close(hide) {
      if (hide) {
        hide();
      }
      this.$emit("done");
    },
  },
};
</script>

<style scoped></style>
