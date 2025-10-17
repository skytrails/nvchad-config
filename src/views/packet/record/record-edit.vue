<!-- 文章编辑弹窗 -->
<template>
  <div>
    <el-drawer
      class="edit-table"
      :title="'筹款详情'"
      :visible.sync="showDrawer"
      :direction="direction"
      :size="'calc(100vw - 256px)'"
      :before-close="close"
    >
      <el-card
        shadow="never"
        style="width: 80%; margin: 50px auto; border: 1px solid #ebeef5"
      >
        <div class="operate-container">
          <i class="el-icon-warning color-danger" style="margin-left: 20px"></i>
          <span class="color-danger">当前筹款状态：{{ form.statusName }}</span>
          <div class="operate-button-container" v-show="form.status === 1">
            <el-button size="mini" @click="showAuditDialog">审核筹款</el-button>
          </div>
        </div>
        <div class="table-title">
          <span class="font-small">筹款信息（{{ form.projectTypeName }}）</span>
        </div>
        <div class="table-layout">
          <template v-if="form.projectType === 1">
            <el-row>
              <el-col :span="6" class="table-cell-title">为谁筹款</el-col>
              <el-col :span="6" class="table-cell-title">患者姓名</el-col>
              <el-col :span="6" class="table-cell-title">患者身份证号</el-col>
              <el-col :span="6" class="table-cell-title">所患疾病</el-col>
            </el-row>
            <el-row>
              <el-col :span="6" class="table-cell">{{
                form.patientRelation
              }}</el-col>
              <el-col :span="6" class="table-cell">{{
                form.patientName
              }}</el-col>
              <el-col :span="6" class="table-cell">{{
                form.patientIdNo
              }}</el-col>
              <el-col :span="6" class="table-cell">{{ form.disease }}</el-col>
            </el-row>
            <el-row>
              <el-col :span="6" class="table-cell-title">手机号码</el-col>
              <el-col :span="6" class="table-cell-title">所在地区</el-col>
              <el-col :span="6" class="table-cell-title">筹多少钱</el-col>
              <el-col :span="6" class="table-cell-title">经济状况</el-col>
            </el-row>
            <el-row>
              <el-col :span="6" class="table-cell">{{
                form.contactPhone
              }}</el-col>
              <el-col :span="6" class="table-cell"
                >{{
                  (form.province ? form.province : "") +
                  (form.city ? form.city : "") +
                  (form.district ? form.district : "")
                }}
              </el-col>
              <el-col :span="6" class="table-cell">{{
                form.targetAmount
              }}</el-col>
              <el-col :span="6" class="table-cell"
                >{{
                  (form.province ? form.province : "") +
                  (form.city ? form.city : "") +
                  (form.district ? form.district : "")
                }}
              </el-col>
            </el-row>
          </template>
          <template v-else>
            <el-row>
              <el-col :span="6" class="table-cell-title">组织机构名称</el-col>
              <el-col :span="6" class="table-cell-title">联系方式</el-col>
              <el-col :span="6" class="table-cell-title">筹多少钱</el-col>
              <el-col :span="6" class="table-cell-title">筹款周期</el-col>
            </el-row>
            <el-row>
              <el-col :span="6" class="table-cell">{{
                form.organizationName
              }}</el-col>
              <el-col :span="6" class="table-cell">{{
                form.contactPhone
              }}</el-col>
              <el-col :span="6" class="table-cell">{{
                form.targetAmount
              }}</el-col>
              <el-col :span="6" class="table-cell"
                >{{ form.startDate }} 至 {{ form.endDate }}</el-col
              >
            </el-row>
          </template>
        </div>
        <div class="table-title">
          <span class="font-small">关联基金</span>
        </div>
        <div class="table-content">
          <el-tag>{{ form.fundId | fundNameById(fundList) }}</el-tag>
        </div>
        <div class="table-title">
          <span class="font-small">{{
            form.projectType === 1 ? "求助标题" : "筹款标题"
          }}</span>
        </div>
        <div class="table-content">
          {{ form.title }}
        </div>
        <div class="table-title">
          <span class="font-small">{{
            form.projectType === 1 ? "求助详情" : "筹款目的说明"
          }}</span>
        </div>
        <div class="table-content">
          {{ form.description }}
        </div>
        <template v-if="form.projectType === 1">
          <div class="table-title">
            <span class="font-small">患者照片</span>
          </div>
          <div class="table-content table-images">
            <template
              v-if="form.patientImagesList && form.patientImagesList.length > 0"
            >
              <el-image
                class="image-item"
                v-for="(item, index) in form.patientImagesList"
                :key="index"
                :src="item"
              ></el-image>
            </template>
            <template v-else>
              <el-empty description="暂无记录"></el-empty>
            </template>
          </div>
          <div class="table-title">
            <span class="font-small">医疗证明：{{ form.medicalType }}</span>
          </div>
          <div class="table-content table-images">
            <template
              v-if="
                form.medicalConditionList &&
                form.medicalConditionList.length > 0
              "
            >
              <el-image
                class="image-item"
                v-for="(item, index) in form.medicalConditionList"
                :key="index"
                :src="item"
              ></el-image>
            </template>
            <template v-else>
              <el-empty description="暂无记录"></el-empty>
            </template>
          </div>
        </template>
        <template v-if="form.projectType === 2">
          <div class="table-title">
            <span class="font-small">筹款项目资料</span>
          </div>
          <div class="table-content table-images">
            <template
              v-if="
                form.proofDocumentsList && form.proofDocumentsList.length > 0
              "
            >
              <el-image
                class="image-item"
                v-for="(item, index) in form.proofDocumentsList"
                :key="index"
                :src="item"
              ></el-image>
            </template>
            <template v-else>
              <el-empty description="暂无记录"></el-empty>
            </template>
          </div>
          <div class="table-title">
            <span class="font-small">公益组织证件</span>
          </div>
          <div class="table-content table-images">
            <template
              v-if="
                form.organizationCertsList &&
                form.organizationCertsList.length > 0
              "
            >
              <el-image
                class="image-item"
                v-for="(item, index) in form.organizationCertsList"
                :key="index"
                :src="item"
              ></el-image>
            </template>
            <template v-else>
              <el-empty description="暂无记录"></el-empty>
            </template>
          </div>
        </template>
      </el-card>
    </el-drawer>
    <!--审核弹窗-->
    <el-dialog
      title="审核筹款项目"
      :visible.sync="auditFormVisible"
      width="40%"
    >
      <el-form
        ref="auditForm"
        :model="auditForm"
        :rules="rules"
        label-width="100px"
      >
        <el-form-item label="审核结果：">
          <el-radio-group v-model="auditForm.status">
            <el-radio :label="2">通过</el-radio>
            <el-radio :label="3">不通过</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="拒绝原因：">
          <el-input v-model="auditForm.rejectReason" type="textarea" rows="3">
          </el-input>
        </el-form-item>
      </el-form>
      <span slot="footer" class="dialog-footer">
        <el-button @click="auditFormVisible = false">取 消</el-button>
        <el-button type="primary" @click="handleAudit">确 定</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
// import uploadImage from '@/components/uploadImage'
import "@riophae/vue-treeselect/dist/vue-treeselect.css";
// import TinymceEditor from '@/components/TinymceEditor';
import { mapGetters } from "vuex";
export default {
  name: "PacketEdit",
  props: {
    // 弹窗是否打开
    visible: Boolean,
    // 修改回显的数据
    data: Object,
    // 栏目数据
    cateList: Array,
  },
  // components: {uploadImage, TinymceEditor},
  data() {
    return {
      showDrawer: this.visible,
      direction: "rtl",
      // 表单数据
      form: Object.assign({ startAt: "", endAt: "" }, this.data),
      // 表单验证规则
      rules: {
        title: [{ required: true, message: "请输入活动标题", trigger: "blur" }],
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

      // 审核弹窗
      auditFormVisible: false,
      auditForm: { status: 0, rejectReason: "" },
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
  },
  filters: {
    fundNameById(id, fundList) {
      // 显式传入fundList
      const fund = fundList.find((item) => item.id == id);
      return fund ? fund.name : "暂无";
    },
  },
  mounted() {
    this.getInfo();
  },
  methods: {
    getInfo() {
      if (this.data.id > 0) {
        this.$http
          .get("/cfProjects/info/" + this.data.id)
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
    showAuditDialog() {
      this.auditFormVisible = true;
      this.auditForm.id = this.form.id;
      this.auditForm.status = this.form.status;
    },
    handleAudit() {
      this.$confirm("是否要提交审核?", "提示", {
        confirmButtonText: "确定",
        cancelButtonText: "取消",
        type: "warning",
      }).then(() => {
        this.$http
          .post("/cfProjects/audit", this.auditForm)
          .then((res) => {
            if (res.data.code === 200) {
              this.auditFormVisible = false;
              this.getInfo();
              this.$message({
                type: "success",
                message: res.data.message,
              });
            } else {
              this.$message.error(res.data.message);
            }
          })
          .catch((e) => {
            this.$message.error(e.message);
          });
      });
    },
  },
};
</script>

<style scoped>
.operate-container {
  background: #f2f6fc;
  height: 80px;
  margin: -20px -20px 0;
  line-height: 80px;
}

.operate-button-container {
  float: right;
  margin-right: 20px;
}

.table-title {
  margin-top: 25px;
  font-weight: bold;
}

.table-layout {
  margin-top: 15px;
  border-left: 1px solid #dcdfe6;
  border-top: 1px solid #dcdfe6;
}

.table-content {
  margin-top: 15px;
}

.table-cell {
  height: 60px;
  line-height: 40px;
  border-right: 1px solid #dcdfe6;
  border-bottom: 1px solid #dcdfe6;
  padding: 10px;
  font-size: 14px;
  color: #606266;
  text-align: center;
  overflow: hidden;
}

.table-cell-title {
  border-right: 1px solid #dcdfe6;
  border-bottom: 1px solid #dcdfe6;
  padding: 10px;
  background: #f2f6fc;
  text-align: center;
  font-size: 14px;
  color: #303133;
}

.table-images {
  display: flex;
  flex-wrap: wrap;
}

.table-images .image-item {
  width: 120px;
  height: 120px;
  margin-right: 15px;
  margin-bottom: 15px;
}

.table-content >>> .el-empty {
  flex: 1;
  padding: 0;
}

.table-content >>> .el-empty__image {
  height: 100px;
}
</style>
