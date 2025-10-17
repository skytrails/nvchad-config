<!-- 文章编辑弹窗 -->
<template>
  <el-drawer
    class="edit-table"
    :title="isUpdate ? '修改新闻' : '添加新闻'"
    :visible.sync="showDrawer"
    :direction="direction"
    :size="'calc(100vw - 256px)'"
    :before-close="close"
  >
    <el-form
      ref="form"
      :model="form"
      :rules="rules"
      label-width="150px"
      style="margin: 10px 30px"
    >
      <el-row :gutter="15">
        <el-col :sm="16">
          <el-form-item label="筹款标题:" prop="title">
            <el-input
              clearable
              :maxlength="20"
              v-model="form.title"
              placeholder="请输入筹款标题"
            />
          </el-form-item>
        </el-col>
        <el-col :sm="16">
          <el-form-item label="基金会:" prop="fundId">
            <el-select
              v-model="form.fundId"
              style="width: 100%"
              clearable
              placeholder="请选择基金"
              @clear="form.fundId = null"
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
          <el-form-item label="筹款详情:" prop="description">
            <el-input
              type="textarea"
              :rows="3"
              v-model="form.description"
              placeholder="请输入筹款详情"
              maxlength="200"
              show-word-limit
            />
          </el-form-item>
          <!--el-form-item label="为谁筹款:" prop="title">
            <el-input
              clearable
              :maxlength="20"
              v-model="form.targetAmount"
              placeholder="请输入筹款金额"
            />
          </el-form-item-->
          <el-form-item label="筹款金额:" prop="targetAmount">
            <el-input
              clearable
              type="number"
              :maxlength="20"
              v-model="form.targetAmount"
              placeholder="请输入筹款金额"
            />
          </el-form-item>
          <el-form-item label="患者姓名:" prop="patientName">
            <el-input
              clearable
              :maxlength="20"
              v-model="form.patientName"
              placeholder="请输入患者姓名"
            />
          </el-form-item>
          <el-form-item label="患者身份证号:" prop="patientIdNo">
            <el-input
              clearable
              :maxlength="20"
              v-model="form.patientIdNo"
              placeholder="请输入身份证号"
            />
          </el-form-item>
          <el-form-item label="所患疾病:" prop="disease">
            <el-input
              clearable
              :maxlength="20"
              v-model="form.disease"
              placeholder="请输入所患疾病"
            />
          </el-form-item>
          <el-form-item label="手机号码:" prop="contactPhone">
            <el-input
              clearable
              :maxlength="20"
              v-model="form.contactPhone"
              placeholder="请输入手机号码"
            />
          </el-form-item>
          <el-form-item label="所在地区:" prop="district">
            <el-input
              clearable
              :maxlength="20"
              v-model="form.district"
              placeholder="请输入所在地区"
            />
          </el-form-item>
          <el-form-item label="经济状况:" prop="economicCondition">
            <el-input
              clearable
              type="textarea"
              :maxlength="20"
              v-model="form.economicCondition"
              placeholder="请输入经济状况"
            />
          </el-form-item>
          <el-form-item label="活动时间:">
            <el-date-picker
              v-model="formDateRange"
              type="daterange"
              range-separator=" - "
              start-placeholder="开始日期"
              end-placeholder="结束日期"
            >
            </el-date-picker>
          </el-form-item>
          <el-form-item label="患者照片：">
            <uploadImage :limit="1" v-model="form.patientImages"></uploadImage>
          </el-form-item>
          <el-form-item label="医疗证明：">
            <uploadImage
              :limit="1"
              v-model="form.medicalCondition"
            ></uploadImage>
          </el-form-item>
        </el-col>
      </el-row>
      <!-- 富文本编辑器 -->
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
// import TinymceEditor from "@/components/TinymceEditor";
import { mapGetters } from "vuex";

export default {
  name: "EventsEdit",
  props: {
    // 弹窗是否打开
    visible: Boolean,
    // 修改回显的数据
    data: Object,
    // 栏目数据
    cateList: Array,
  },
  components: { uploadImage },
  data() {
    return {
      showDrawer: this.visible,
      direction: "rtl",
      // 表单数据
      form: Object.assign({ startDate: "", endDate: "" }, this.data),
      // 表单验证规则
      rules: {
        title: [{ required: true, message: "请输入筹款标题", trigger: "blur" }],
        fundId: [{ required: true, message: "请选择基金会", trigger: "blur" }],
        description: [{ required: true, message: "请输入筹款详情", trigger: "blur" }],
        targetAmount: [{ required: true, message: "请输入筹款金额", trigger: "blur" }],
        patientName: [{ required: true, message: "请输入患者姓名", trigger: "blur" }],
        patientIdNo: [{ required: true, message: "请输入患者身份证", trigger: "blur" }],
        disease: [{ required: true, message: "请输入患者疾病", trigger: "blur" }],
        contactPhone: [{ required: true, message: "请输入联系方式", trigger: "blur" }],
        district: [{ required: true, message: "请输入所在地区", trigger: "blur" }],
        economicCondition: [{ required: true, message: "请输入经济状况", trigger: "blur" }],
        status: [
          { required: true, message: "请选择活动状态", trigger: "blur" },
        ],
        sort: [{ required: true, message: "请输入排序号", trigger: "blur" }],
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
    // 初始化富文本
    ...mapGetters(["fundList"]),
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
    formDateRange: {
      get() {
        return [this.form.startDate, this.form.endDate];
      },
      set(val) {
        this.form.startDate = this.$util.toDateString(val[0], 'yyyy-MM-dd HH:mm:ss')
        this.form.endDate = this.$util.toDateString(val[1], 'yyyy-MM-dd HH:mm:ss');
      },
    },
  },
  mounted() {
    this.getInfo();
  },
  methods: {
    fundNameById(id, fundList) {
      // 显式传入fundList
      const fund = fundList.find((item) => item.id == id);
      return fund ? fund.name : "暂无";
    },
    /* 获取文章详情 */
    getInfo() {
      if (this.data.id > 0) {
        this.$http
          .get("/cfProjects/info/" + this.data.id)
          .then((res) => {
            if (res.data.code === 200) {
              this.form = res.data.data;
              console.log('------:', this.form);
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
        console.log('------fundList:', this.fundList);
        if (valid) {
          this.loading = true;
          this.$http
            .post(
              this.isUpdate ? "/cfProjects/add" : "/cfProjects/add",
              {...this.form, organizationName: this.fundNameById(this.form.fundId, this.fundList)}
            )
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
